import SwiftData

@Model
final class Currency {

  // MARK: Lifecycle

  init(
    name: String,
    avatar: Avatar? = nil,
  ) {
    self.name = name
    self.avatar = avatar
  }

  // MARK: Internal

  @Attribute(.unique) var name: String
  @Relationship(.unique, deleteRule: .cascade) var avatar: Avatar?
}
