import Foundation
import SwiftData
import SwiftUI

extension EnvironmentValues {
  @Entry var navigate = NavigateAction(action: { _ in })
  @Entry var accentColor = AccentColorAction(action: { _ in })
  @Entry var stateManager: any StateManagerProtocol = NullStateManager()
}

// MARK: - App

@main struct App: SwiftUI.App {

  // MARK: Lifecycle

  init() {
    accentColor = .accentColor

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

    do {
      let modelConfig = ModelConfiguration(isStoredInMemoryOnly: false)

      modelContainer = try ModelContainer(for: schema, configurations: modelConfig)

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
        .sheet(item: self.$stateManager.sheet) { route in
          view(route: route)
            .presentationDetents([.large], selection: self.$stateManager.sheetPresentationDetent)
            .presentationDragIndicator(.automatic)
        }
      }
      .onNavigate { type in
        self.stateManager.navigate(type: type)
      }
      .onAccentColor { color in
        self.accentColor = color
      }
      .environment(stateManager)
      .accentColor(accentColor)
      .preferredColorScheme(.light)
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

    case .person(let personId):
      PersonView(personId: personId)

    case .selectAvatar(let avatarId):
      SelectAvatarView(avatarId: avatarId)
    }
  }

  // MARK: Private

  @State private var stateManager: StateManager
  @State private var accentColor: Color

  private let modelContainer: ModelContainer
}
