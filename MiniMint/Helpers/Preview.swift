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

      // Seed a little recent-activity history so dashboards preview populated.
      let deposits = family.actions.filter { $0.actionType == .deposit }
      let children = family.people.filter { $0.role == .child }
      for (personIndex, person) in children.enumerated() {
        guard let ledger = person.ledger else { continue }
        for (actionIndex, action) in deposits.shuffled().prefix(2).enumerated() {
          let hoursAgo = Double(personIndex * 2 + actionIndex + 1)
          let entry = LedgerEntry(ledger: ledger, date: .now.addingTimeInterval(-hoursAgo * 3600), action: action)
          ledger.entries?.append(entry)
          modelContainer.mainContext.insert(entry)
        }
      }

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
