import Foundation
import SwiftData

// MARK: - ScheduledActionFrequency

enum ScheduledActionFrequency: Int, Codable, CaseIterable, Identifiable {
  case once
  case recurring

  // MARK: Internal

  var id: Self { self }
}

// MARK: - ScheduledAction

@Model
final class ScheduledAction {

  // MARK: Lifecycle

  init(
    name: String,
    action: Action,
    person: Person,
    family: Family? = nil,
    frequency: ScheduledActionFrequency = .once,
    intervalDays: Int = 1,
    startDate: Date = .now,
    isActive: Bool = true,
    note: String? = nil,
  ) {
    self.name = name
    self.action = action
    self.person = person
    self.family = family
    self.frequency = frequency.rawValue
    self.intervalDays = intervalDays
    self.startDate = startDate
    self.isActive = isActive
    self.note = note
  }

  // MARK: Public

  public var frequency: Int

  @Transient
  public var scheduleFrequency: ScheduledActionFrequency {
    ScheduledActionFrequency(rawValue: frequency) ?? .once
  }

  // MARK: Internal

  var name: String
  var intervalDays: Int = 1
  var startDate: Date = Date.now
  var lastExecutedDate: Date?
  var isActive: Bool = true
  var note: String?

  @Relationship var action: Action?
  @Relationship(inverse: \Person.scheduledActions) var person: Person?
  @Relationship(inverse: \Family.scheduledActions) var family: Family?

}
