import Foundation
import SwiftData
import SwiftUI

extension EnvironmentValues {
  @Entry var navigate = NavigateAction(action: { _ in })
  @Entry var stateManager: any StateManagerProtocol = NullStateManager()
}

// MARK: - App

@main struct App: SwiftUI.App {

  // MARK: Lifecycle

  init() {
    let schema = Schema([
      Avatar.self,
      Family.self,
      Currency.self,
      Person.self,
    ])

    do {
      modelContainer = try ModelContainer(for: schema)

      stateManager = StateManager(modelContext: modelContainer.mainContext)
      stateManager.restore()
    } catch let error {
      fatalError("cannot set up modelContainer: \(error)")
    }
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      NavigationStack(path: self.$stateManager.path) {
        ZStack {
          initialView()
        }
        .navigationDestination(for: Route.self) { route in
          view(route: route)
        }
      }
      .onNavigate { type in
        self.stateManager.navigate(type: type)
      }
      .environment(stateManager)
    }
    .modelContainer(modelContainer)
  }

  @ViewBuilder func initialView() -> some View {
    if stateManager.hasCompletedSetup {
      HomeView()
    } else {
      OnboardingView()
    }
  }

  @ViewBuilder func view(route: Route) -> some View {
    switch route {
    case .onboarding:
      OnboardingView()
    case .setup:
      SetupView()
    case .home:
      HomeView()
    }
  }

  // MARK: Private

  @State private var stateManager: StateManager

  private let modelContainer: ModelContainer
}
