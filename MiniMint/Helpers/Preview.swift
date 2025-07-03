import Foundation
import SwiftData

@MainActor
class Preview {

  // MARK: Lifecycle

  init() {
    let schema = Schema([
      Avatar.self,
      Family.self,
      Currency.self,
      Person.self,
    ])

    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    do {
      modelContainer = try ModelContainer(
        for: schema,
        configurations: config,
      )

      let family = Family(
        name: "Jetsons",
        avatar: Avatar(emoji: 0x1F680),
        currency: Currency(name: "Credits"),
        people: [
          Person(name: "George", role: .parent),
          Person(name: "Jane", role: .parent),
          Person(name: "Judy", role: .child),
          Person(name: "Elroy", role: .child),
        ],
      )

      modelContainer.mainContext.insert(family)

      stateManager = StateManager(modelContext: modelContainer.mainContext)
    } catch {
      fatalError("Could not initialize ModelContainer")
    }
  }

  // MARK: Internal

  var modelContainer: ModelContainer
  var stateManager: StateManager
}
