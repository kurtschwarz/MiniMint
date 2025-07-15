import SwiftData

// MARK: - Action

@Model
final class ActionGroup {

  // MARK: Lifecycle

  init(name: String, family: Family? = nil) {
    self.name = name
    self.family = family
  }

  // MARK: Internal

  var name: String
  @Relationship(inverse: \Family.actionGroups) var family: Family?

  static func generateDefaults() -> [ActionGroup] {
    return [
      .init(name: "Chores"),
      .init(name: "Physical"),
      .init(name: "Cognitive"),
      .init(name: "Social/Emotional"),
      .init(name: "Creative"),
      .init(name: "Other"),
    ]
  }
}
