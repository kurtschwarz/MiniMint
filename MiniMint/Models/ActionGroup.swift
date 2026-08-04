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
      make(name: "Helping Hands", actions: [
        ("Helped without being asked", 5),
        ("Took on someone else's task to help", 5),
        ("Volunteered for the least fun job", 4),
        ("Noticed a mess and cleaned it up", 4),
        ("Did a job carefully and thoroughly", 3),
      ]),
      make(name: "Physical", actions: [
        ("Tried a new activity despite nerves", 5),
        ("Practiced a skill they're still learning", 5),
        ("Kept going when tired instead of quitting", 4),
        ("Got outside and moved for fun", 3),
        ("Chose a healthy snack on their own", 3),
        ("Went to bed calmly", 3),
      ]),
      make(name: "Cognitive", actions: [
        ("Stuck with a hard problem", 6),
        ("Taught someone what they learned", 6),
        ("Read something new by choice", 5),
        ("Tried a different approach after failing", 5),
        ("Changed their mind for a good reason", 5),
        ("Asked a thoughtful question", 4),
        ("Admitted not knowing and looked it up", 4),
        ("Planned ahead for something", 4),
      ]),
      make(name: "Social/Emotional", actions: [
        ("Comforted someone who was upset", 10),
        ("Stood up for someone kindly", 8),
        ("Apologized sincerely, unprompted", 8),
        ("Included someone being left out", 8),
        ("Named a big feeling instead of acting out", 7),
        ("Shared something they care about", 6),
        ("Forgave someone and moved on", 6),
        ("Gave a genuine compliment", 5),
        ("Checked in on someone's day", 5),
        ("Waited patiently for their turn", 5),
      ]),
      make(name: "Creative", actions: [
        ("Turned a mistake into part of the art", 6),
        ("Solved a problem in an unexpected way", 6),
        ("Made something and shared it", 5),
        ("Invented a game or story", 5),
        ("Kept working on a project across days", 5),
        ("Performed for the family", 4),
      ]),
    ]
  }

  // MARK: Private

  private static func make(name: String, actions: [(String, UInt64)]) -> ActionGroup {
    let group = ActionGroup(name: name)
    group.actions = actions.map { name, amount in
      let action = Action(name: name, type: .deposit, amount: amount)
      action.group = group
      return action
    }
    return group
  }
}
