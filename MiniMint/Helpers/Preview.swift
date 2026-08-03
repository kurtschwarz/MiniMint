import Foundation
import SwiftData

@MainActor
class Preview {

  // MARK: Lifecycle

  init() {
    modelContainer = SwiftDataManager.shared.container

    do {
      family = Family(
        name: "Jetsons",
        avatar: Avatar(emoji: 0x1F680),
        currency: Currency(name: "Credits"),
        people: [
          Person(name: "George", role: .parent, avatar: .init(emoji: 0x1F9A9, background: 0xEEE0FF)),
          Person(name: "Jane", role: .parent, avatar: .init(emoji: 0x1F9A9, background: 0xEEE0FF)),
          Person(name: "Judy", role: .child, balance: 100, avatar: .init(emoji: 0x1F9A9, background: 0xEEE0FF)),
          Person(name: "Elroy", role: .child, balance: 250, avatar: .init(emoji: 0x1F680, background: 0xDFFFFD)),
        ],
        actionGroups: ActionGroup.generateDefaults(),
      )

      modelContainer.mainContext.insert(family)
      try modelContainer.mainContext.save()

      stateManager = StateManager(modelContext: modelContainer.mainContext)
      stateManager.familyId = family.persistentModelID
      stateManager.family = family
    } catch {
      fatalError("Could not initialize ModelContainer")
    }
  }

  // MARK: Internal

  var modelContainer: ModelContainer
  var stateManager: StateManager

  var family: Family
}
