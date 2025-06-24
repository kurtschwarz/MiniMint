import Foundation
import SwiftData

@MainActor
class Preview {

  // MARK: Lifecycle

  init() {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    do {
      modelContainer = try ModelContainer(
        for: Family.self, Currency.self, Person.self,
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
    } catch {
      fatalError("Could not initialize ModelContainer")
    }

    appState = AppState()
  }

  // MARK: Internal

  let modelContainer: ModelContainer
  let appState: AppState
}
