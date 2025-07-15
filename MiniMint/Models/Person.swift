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

  init(name: String, role: Role, balance: Int64 = 0, family: Family? = nil, avatar: Avatar? = nil) {
    self.name = name
    self.role = role
    self.balance = balance
    self.family = family
    self.avatar = avatar

    ledger = .init()
  }

  // MARK: Internal

  var name: String
  var role: Role
  var balance: Int64 = 0
  @Relationship(.unique, deleteRule: .cascade) var avatar: Avatar?
  @Relationship(inverse: \Family.people) var family: Family?
  @Relationship(deleteRule: .cascade) var ledger: Ledger?
}
