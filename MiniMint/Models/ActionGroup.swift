import SwiftData

// MARK: - Action

@Model
final class ActionGroup {

  // MARK: Lifecycle

  init(name: String, family: Family? = nil, actions: [Action] = []) {
    self.name = name
    self.family = family
    self.actions = actions
  }

  // MARK: Internal

  var name: String

  @Relationship(inverse: \Family.actionGroups) var family: Family?
  @Relationship(deleteRule: .nullify) var actions: [Action] = []

  static func generateDefaults() -> [ActionGroup] {
    return [
      .init(name: "Chores"),
      .init(name: "Physical"),
      .init(name: "Cognitive"),
      .init(name: "Social/Emotional"),
      .init(name: "Creative"),
    ]
  }
}
