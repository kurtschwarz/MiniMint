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

  init(name: String, role: Role, family: Family? = nil, avatar: Avatar? = nil) {
    self.name = name
    self.role = role
    self.family = family
    self.avatar = avatar
  }

  // MARK: Internal

  var name: String
  var role: Role
  @Relationship(.unique, deleteRule: .cascade) var avatar: Avatar?
  @Relationship(inverse: \Family.people) var family: Family?
}
