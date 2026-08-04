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
    self.balance = balance
    self.family = family
    self.avatar = avatar
    self.sortOrder = sortOrder

    ledger = .init()
  }

  // MARK: Internal

  var name: String
  var role: Role
  var balance: Int64 = 0
  /// Position within its role's list, controlled by drag-to-reorder in the crew list.
  var sortOrder: Int = 0
  @Relationship(.unique, deleteRule: .cascade) var avatar: Avatar?
  @Relationship(inverse: \Family.people) var family: Family?
  @Relationship(deleteRule: .cascade) var ledger: Ledger?
  /// Actions private to this person; deleted along with the person.
  @Relationship(deleteRule: .cascade, inverse: \Action.owner) var ownedActions: [Action] = []
}
