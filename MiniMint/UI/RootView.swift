import SwiftUI

enum States: Hashable {
  case onboarding
  case dashboard
}

enum Sheets: String, Identifiable {
  var id: String {
    self.rawValue
  }

  case setup
}

class RootCoordinator: ObservableObject {
  @Published var path: NavigationPath = NavigationPath()

  @Published var state: States?
  @Published var sheet: Sheets?

  @ViewBuilder
  func build (state: States) -> some View {
    switch state {
    case .onboarding:
      OnboardingView()
    case .dashboard:
      DashboardView()
    }
  }

  @ViewBuilder
  func buildSheet (sheet: Sheets) -> some View {
    switch sheet {
    case .setup:
      SetupView()
    }
  }

  init () {
    var state: States = .onboarding
    if (UserDefaults.standard.bool(forKey: "completedOnboarding")) {
      state = .dashboard
    }

    self.state = state
    self.path.append(state)
  }

  func push (state: States) {
    self.state = state
    self.path.append(state)
  }

  func presentSheet (_ sheet: Sheets) {
    self.sheet = sheet
  }

  func dismissSheet () {
    self.sheet = nil
  }

  func completeOnboarding () {
    UserDefaults.standard.setValue(true, forKey: "completedOnboarding")
    self.push(state: .dashboard)
  }
}

struct RootView: View {
  @StateObject private var coordinator = RootCoordinator()

  var body: some View {
    NavigationStack(path: $coordinator.path) {
      VStack {}
        .navigationDestination(for: States.self) { state in
          coordinator.build(state: state)
        }
        .sheet(item: $coordinator.sheet) { sheet in
          coordinator.buildSheet(sheet: sheet)
        }
    }
    .environmentObject(coordinator)
  }
}

#Preview {
  RootView()
}
