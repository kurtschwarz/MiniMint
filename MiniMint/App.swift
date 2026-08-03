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
    stateManager = StateManager(modelContext: SwiftDataManager.shared.container.mainContext)
    stateManager.restore()
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
        .sheet(item: self.$stateManager.sheet) { route in
          view(route: route)
            .presentationDetents([.medium, .large], selection: self.$stateManager.sheetPresentationDetent)
            .presentationDragIndicator(.automatic)
        }
      }
      .onNavigate { type in
        self.stateManager.navigate(type: type)
      }
      .environment(stateManager)
      .preferredColorScheme(.light)
    }
    .modelContainer(SwiftDataManager.shared.container)
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

    case .person(let personId):
      PersonView(personId: personId)

    case .createPerson(let role):
      CreatePersonView(role: role)

    case .selectAvatar(let avatarId):
      SelectAvatarView(avatarId: avatarId)

    case .createAction(let personId):
      CreateActionView(personId: personId)

    case .createReward:
      CreateRewardView()
    }
  }

  // MARK: Private

  @State private var stateManager: StateManager
}
