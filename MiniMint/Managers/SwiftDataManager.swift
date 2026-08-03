import Foundation
import SwiftData

@MainActor public struct SwiftDataManager {

  // MARK: Lifecycle

  init() {
    let schema = Schema([
      Avatar.self,
      Family.self,
      Currency.self,
      Person.self,
      Action.self,
      ActionGroup.self,
      Ledger.self,
      LedgerEntry.self,
    ])

    #if DEBUG
    guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else {
      container = try! ModelContainer(
        for: schema,
        configurations: [
          ModelConfiguration(schema: schema, isStoredInMemoryOnly: true),
        ],
      )

      return
    }
    #endif

    container = try! ModelContainer(
      for: schema,
      configurations: [
        ModelConfiguration(schema: schema),
      ],
    )
  }

  // MARK: Public

  public static let shared = SwiftDataManager()

  public var container: ModelContainer

}
