import Foundation
import Observation
import SwiftData
import SwiftUI

// MARK: - Route

enum Route: Hashable {
  case onboarding
  case setup
  case home
  case person(PersistentIdentifier)
}

// MARK: - NavigateAction

struct NavigateAction {
  typealias Action = (NavigationType) -> Void

  let action: Action

  func callAsFunction(_ navigationType: NavigationType) {
    action(navigationType)
  }
}

// MARK: - NavigationType

enum NavigationType: Hashable {
  case push(Route)
  case unwind(Route)
  case back
}

// MARK: - StateManagerProtocol

protocol StateManagerProtocol: AnyObject, Observable {
  var family: Family? { get set }
  var familyId: PersistentIdentifier? { get set }

  var hasCompletedSetup: Bool { get set }
}

// MARK: - StateManager

@Observable class StateManager: StateManagerProtocol {

  // MARK: Lifecycle

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  // MARK: Internal

  var family: Family? = nil
  var path: [Route] = []
  var hasCompletedSetup = false

  var familyId: PersistentIdentifier? {
    get {
      guard let data = UserDefaults.standard.data(forKey: "familyId") else {
        return nil
      }

      return try? JSONDecoder().decode(Family.ID.self, from: data)
    }

    set {
      let data = try! JSONEncoder().encode(newValue)
      UserDefaults.standard.setValue(data, forKey: "familyId")
    }
  }

  func navigate(type: NavigationType) {
    switch type {
    case .push(let route):
      path.append(route)

    case .unwind(let route):
      if route == .home {
        path = []
      } else {
        guard let index = path.firstIndex(where: { $0 == route }) else {
          return
        }

        path = Array(path.prefix(upTo: index + 1))
      }

    case .back:
      path.removeLast()
    }
  }

  func reset() {
    guard let family else {
      return
    }

    do {
      try modelContext.transaction {
        modelContext.delete(family)
        try modelContext.save()
      }
    } catch {
      print("Unexpected error: \(error).")
    }

    familyId = nil
    hasCompletedSetup = false
    path = []
  }

  func restore() {
    if familyId != nil {
      family = modelContext.model(for: familyId!) as? Family
      hasCompletedSetup = true
    }
  }

  // MARK: Private

  private let modelContext: ModelContext

}

// MARK: - NullStateManager

final class NullStateManager: StateManagerProtocol {
  var family: Family? = nil
  var familyId: PersistentIdentifier? = nil

  var hasCompletedSetup = false
}
