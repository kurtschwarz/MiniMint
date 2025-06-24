import SwiftData

@Model
final class Family {

  // MARK: Lifecycle

  init(
    name: String,
    avatar: Avatar? = nil,
    currency: Currency? = nil,
    people: [Person]? = nil,
  ) {
    self.name = name
    self.avatar = avatar
    self.currency = currency
    self.people = people
  }

  // MARK: Internal

  @Attribute(.unique) var name: String
  @Relationship(.unique, deleteRule: .cascade) var avatar: Avatar?
  @Relationship(.unique, deleteRule: .cascade) var currency: Currency?
  @Relationship(deleteRule: .cascade) var people: [Person]?
}
