import SwiftData
import SwiftUI

// MARK: - AllowanceFrequency

enum AllowanceFrequency: Int, CaseIterable, Identifiable {
  case weekly = 7
  case biweekly = 14
  case monthly = 30

  // MARK: Internal

  var id: Self { self }

  var label: String {
    switch self {
    case .weekly: "Weekly"
    case .biweekly: "Biweekly"
    case .monthly: "Monthly"
    }
  }
}

// MARK: - AllowanceView

struct AllowanceView: View {

  // MARK: Lifecycle

  init(person: Person) {
    self.person = person
  }

  // MARK: Internal

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Amount")) {
          HStack {
            Text(person.family?.currency?.name ?? "Coins")

            TextField(
              "Amount",
              value: $amount,
              format: .number.grouping(.automatic),
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
          }
        }

        Section(header: Text("Frequency")) {
          Picker("Frequency", selection: $frequency) {
            ForEach(AllowanceFrequency.allCases) { freq in
              Text(freq.label).tag(freq)
            }
          }
          .pickerStyle(.segmented)

          DatePicker("Starting", selection: $startDate, displayedComponents: .date)
        }

        Section {
          Toggle("Enabled", isOn: $isEnabled)
        }

        Button(action: save) {
          Text(hasExisting ? "Save Changes" : "Set Allowance")
        }
        .disabled(!canSave)

        if isDeveloperToolingAvailable {
          Section(header: Text("Developer Tools")) {
            Button("Test Push Notification") {
              NotificationManager.shared.sendTestNotification(for: person)
            }

            Button("Deposit Allowance Now") {
              depositNow()
            }
            .disabled(!canSave)
          }
        }
      }
      .navigationTitle("Allowance")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Cancel")
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(action: save) {
            Image(systemName: "checkmark")
          }
          .disabled(!canSave)
          .accessibilityLabel("Save")
        }
      }
      .listStyle(.plain)
    }
    .onAppear(perform: loadExisting)
  }

  // MARK: Private

  private static let systemActionName = "Allowance"

  private let person: Person

  @State private var amount: UInt64 = 0
  @State private var frequency = AllowanceFrequency.weekly
  @State private var startDate = Date.now
  @State private var hasExisting = false
  @State private var isEnabled = true

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.ledgerManager) private var ledgerManager

  private var canSave: Bool {
    amount > 0
  }

  private func loadExisting() {
    guard let schedule = findExistingSchedule() else { return }

    hasExisting = true
    amount = schedule.action?.amount ?? 0
    startDate = schedule.startDate
    isEnabled = schedule.isActive

    if let freq = AllowanceFrequency(rawValue: schedule.intervalDays) {
      frequency = freq
    }
  }

  private func save() {
    guard amount > 0 else { return }

    let action = findOrCreateAction()
    action.amount = amount

    if let schedule = findExistingSchedule() {
      schedule.intervalDays = frequency.rawValue
      schedule.startDate = startDate
      schedule.isActive = isEnabled
    } else {
      let schedule = ScheduledAction(
        name: Self.systemActionName,
        action: action,
        person: person,
        family: person.family,
        frequency: .recurring,
        intervalDays: frequency.rawValue,
        startDate: startDate,
        isActive: isEnabled,
      )
      modelContext.insert(schedule)
    }

    try? modelContext.save()
    NotificationManager.shared.refresh(for: person)
    dismiss()
  }

  /// Developer tool: post the allowance to the ledger immediately, using the
  /// amount currently entered, without waiting for the schedule to come due.
  private func depositNow() {
    guard amount > 0 else { return }

    let action = findOrCreateAction()
    action.amount = amount
    try? modelContext.save()

    try? ledgerManager?.record(action: action, for: person)
  }

  private func findExistingSchedule() -> ScheduledAction? {
    person.scheduledActions.first { $0.action?.actionType == .allowance }
  }

  private func findOrCreateAction() -> Action {
    if let existing = person.ownedActions.first(where: { $0.actionType == .allowance }) {
      return existing
    }

    let action = Action(
      name: Self.systemActionName,
      type: .allowance,
      amount: amount,
    )
    action.owner = person
    action.family = person.family
    modelContext.insert(action)
    return action
  }

}
