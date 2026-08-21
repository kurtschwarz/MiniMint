import Foundation
import SwiftData
import UserNotifications

// MARK: - ForegroundPresenter

/// Lets allowance notifications show as a banner (with sound) even while the
/// app is open, which iOS otherwise suppresses.
private final class ForegroundPresenter: NSObject, UNUserNotificationCenterDelegate {
  static let shared = ForegroundPresenter()

  func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent _: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void,
  ) {
    completionHandler([.banner, .sound])
  }
}

// MARK: - NotificationManager

/// Schedules the local notifications that remind a family an allowance is due.
///
/// iOS caps an app at 64 pending notifications and cannot repeat a
/// notification on an arbitrary N-day cadence, so instead of one repeating
/// trigger we pre-schedule the next handful of concrete occurrences for each
/// active allowance and re-seed them whenever the schedule changes or the app
/// launches.
struct NotificationManager {

  // MARK: Internal

  static let shared = NotificationManager()

  /// Ask once for permission to show alerts, and install the delegate that lets
  /// notifications surface while the app is in the foreground. Safe to call on
  /// every launch; iOS only prompts the first time.
  func requestAuthorization() {
    center.delegate = ForegroundPresenter.shared
    center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
  }

  /// Rebuild every allowance reminder in the store. Call on launch so reminders
  /// keep rolling forward as older occurrences fire and fall off.
  func rescheduleAll(in context: ModelContext) {
    let schedules = (try? context.fetch(FetchDescriptor<ScheduledAction>())) ?? []
    let plans = schedules.compactMap(plan(for:))
    install(plans: plans, clearingAllAllowances: true, removingPrefixes: [])
  }

  /// Re-seed the reminders owned by `person`'s allowance schedules, cancelling
  /// any that are now disabled or removed. Call after editing an allowance.
  func refresh(for person: Person) {
    let allowanceSchedules = person.scheduledActions.filter { $0.action?.actionType == .allowance }
    let plans = allowanceSchedules.compactMap(plan(for:))
    let prefixes = allowanceSchedules.map { prefix(for: $0.id) }
    install(plans: plans, clearingAllAllowances: false, removingPrefixes: prefixes)
  }

  /// Whether the in-app debug tooling (e.g. the "Test Notification" button)
  /// should be shown: only in the simulator or a TestFlight (sandbox receipt)
  /// build, never in a shipped App Store build.
  static var isDebugToolingAvailable: Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    #endif
  }

  /// Fire a one-off allowance notification a few seconds out so the exact copy
  /// can be eyeballed without waiting for a real due date. Debug tooling only.
  func sendTestNotification(for person: Person) {
    let amount = person.ownedActions.first { $0.actionType == .allowance }?.amount ?? 0
    let currencyName = person.family?.currency?.name ?? "Coins"

    let content = UNMutableNotificationContent()
    content.title = "\u{1F4B0} \(person.name)'s allowance deposited"
    content.body = "\(amount) \(currencyName)"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(
      identifier: "\(Self.identifierPrefix).test.\(UUID().uuidString)",
      content: content,
      trigger: trigger,
    )
    center.add(request)
  }

  // MARK: Private

  /// A value snapshot of one allowance schedule, so the notification work can
  /// run off SwiftData's context without touching model objects on other
  /// threads.
  private struct AllowancePlan {
    let identifier: UUID
    let personName: String
    let amount: UInt64
    let currencyName: String
    let startDate: Date
    let intervalDays: Int
  }

  /// How many upcoming occurrences to pre-schedule per allowance. Kept well
  /// under the system's 64-notification budget to leave room for several kids.
  private static let occurrenceCount = 12
  private static let identifierPrefix = "allowance"

  private let center = UNUserNotificationCenter.current()

  private func prefix(for identifier: UUID) -> String {
    "\(Self.identifierPrefix).\(identifier.uuidString)."
  }

  /// Build a plan from an active, funded allowance schedule; `nil` otherwise.
  private func plan(for schedule: ScheduledAction) -> AllowancePlan? {
    guard
      schedule.isActive,
      schedule.action?.actionType == .allowance,
      let amount = schedule.action?.amount, amount > 0,
      let person = schedule.person,
      schedule.intervalDays > 0
    else {
      return nil
    }

    return AllowancePlan(
      identifier: schedule.id,
      personName: person.name,
      amount: amount,
      currencyName: person.family?.currency?.name ?? "Coins",
      startDate: schedule.startDate,
      intervalDays: schedule.intervalDays,
    )
  }

  private func install(plans: [AllowancePlan], clearingAllAllowances: Bool, removingPrefixes: [String]) {
    center.getPendingNotificationRequests { pending in
      let stale = pending
        .map(\.identifier)
        .filter { id in
          if clearingAllAllowances {
            return id.hasPrefix("\(Self.identifierPrefix).")
          }
          return removingPrefixes.contains { id.hasPrefix($0) }
        }

      if !stale.isEmpty {
        center.removePendingNotificationRequests(withIdentifiers: stale)
      }

      for plan in plans {
        schedule(plan)
      }
    }
  }

  private func schedule(_ plan: AllowancePlan) {
    let content = UNMutableNotificationContent()
    content.title = "\u{1F4B0} \(plan.personName)'s allowance deposited"
    content.body = "\(plan.amount) \(plan.currencyName)"
    content.sound = .default

    let calendar = Calendar.current
    for (index, date) in upcomingDates(for: plan, from: .now).enumerated() {
      let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      let request = UNNotificationRequest(
        identifier: "\(prefix(for: plan.identifier))\(index)",
        content: content,
        trigger: trigger,
      )
      center.add(request)
    }
  }

  /// The next `occurrenceCount` due dates at or after `now`, walking forward
  /// from the start date in `intervalDays` steps. Day-based arithmetic keeps
  /// the wall-clock time steady across daylight-saving shifts.
  private func upcomingDates(for plan: AllowancePlan, from now: Date) -> [Date] {
    let calendar = Calendar.current
    var date = plan.startDate

    while date < now {
      guard let next = calendar.date(byAdding: .day, value: plan.intervalDays, to: date) else {
        return []
      }
      date = next
    }

    var dates: [Date] = []
    while dates.count < Self.occurrenceCount {
      dates.append(date)
      guard let next = calendar.date(byAdding: .day, value: plan.intervalDays, to: date) else {
        break
      }
      date = next
    }
    return dates
  }

}
