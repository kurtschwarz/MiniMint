import SwiftData

// MARK: - Role

enum Role: Codable {
  case parent
  case child
}

// MARK: - Person

@Model
final class Person {

  // MARK: Lifecycle

  init(
    name: String,
    role: Role,
    balance: Int64 = 0,
    family: Family? = nil,
    avatar: Avatar? = nil,
    sortOrder: Int = 0,
  ) {
    self.name = name
    self.role = role
    self.family = family
    self.avatar = avatar
    self.sortOrder = sortOrder

    ledger = Ledger(balance: balance)
  }

  // MARK: Internal

  var name: String
  var role: Role
  /// Position within its role's list, controlled by drag-to-reorder in the crew list.
  var sortOrder = 0

  @Relationship(.unique, deleteRule: .cascade) var avatar: Avatar?
  @Relationship(inverse: \Family.people) var family: Family?
  /// The person's wallet. One-to-one for now; becomes one-to-many if we add
  /// named "buckets" a person can split funds across.
  @Relationship(deleteRule: .cascade) var ledger: Ledger?
  /// Actions private to this person; deleted along with the person.
  @Relationship(deleteRule: .cascade, inverse: \Action.owner) var ownedActions: [Action] = []
  @Relationship(deleteRule: .cascade) var scheduledActions: [ScheduledAction] = []

  /// Convenience access to the wallet balance. Reading and writing
  /// `person.balance` forwards to the person's `ledger`.
  @Transient var balance: Int64 {
    get { ledger?.balance ?? 0 }
    set { ledger?.balance = newValue }
  }

  @discardableResult
  func ensureAllowance(context: ModelContext) -> (action: Action, schedule: ScheduledAction)? {
    guard role == .child else {
      return nil
    }

    if let existingAction = ownedActions.first(where: { $0.actionType == .allowance }),
       let existingSchedule = scheduledActions.first(where: { $0.action?.actionType == .allowance })
    {
      return (existingAction, existingSchedule)
    }

    let action = Action(name: "Allowance", type: .allowance)
    action.owner = self
    action.family = family

    let schedule = ScheduledAction(
      name: "Allowance",
      action: action,
      person: self,
      family: family,
      frequency: .recurring,
      intervalDays: AllowanceFrequency.weekly.rawValue,
      isActive: false,
    )

    context.insert(action)
    context.insert(schedule)

    return (action, schedule)
  }

}
