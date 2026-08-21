import Foundation
import SwiftData
import SwiftUI

extension EnvironmentValues {
  @Entry var navigate = NavigateAction(action: { _ in })
  @Entry var stateManager: any StateManagerProtocol = NullStateManager()
  @Entry var ledgerManager: LedgerManager? = nil
}

// MARK: - App

@main struct App: SwiftUI.App {

  // MARK: Lifecycle

  init() {
    let modelContext = SwiftDataManager.shared.container.mainContext

    stateManager = StateManager(modelContext: modelContext)
    ledgerManager = LedgerManager(modelContext: modelContext)

    stateManager.restore()

    NotificationManager.shared.requestAuthorization()
    NotificationManager.shared.rescheduleAll(in: modelContext)
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      NavigationStack(path: $stateManager.path) {
        ZStack {
          initialView()
        }
        .navigationDestination(for: Route.self) { route in
          view(route: route)
        }
        .sheet(item: $stateManager.sheet) { route in
          if route.isFixedSize {
            view(route: route)
              .presentationDetents([.large])
              .presentationDragIndicator(.hidden)
          } else {
            view(route: route)
              .presentationDetents([.medium, .large], selection: $stateManager.sheetPresentationDetent)
              .presentationDragIndicator(.automatic)
          }
        }
      }
      .onNavigate { type in
        stateManager.navigate(type: type)
      }
      .environment(stateManager)
      .environment(\.ledgerManager, ledgerManager)
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

    case .recordAction(let actionId, let personId):
      RecordActionView(actionId: actionId, personId: personId)
    }
  }

  // MARK: Private

  @State private var stateManager: StateManager

  private let ledgerManager: LedgerManager
}
