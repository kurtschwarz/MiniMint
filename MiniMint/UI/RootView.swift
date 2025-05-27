import SwiftUI

enum States: Hashable {
  case onboarding
  case dashboard
}

enum UserDefaultKeys {
  static let completedOnboarding = "completedOnboarding"
}

class RootCoordinator: ObservableObject {
  @Published var path: NavigationPath = NavigationPath()
  @Published var state: States

  @ViewBuilder
  func build (state: States) -> some View {
    switch state {
    case .onboarding:
      OnboardingView()
    case .dashboard:
      DashboardView()
    }
  }

  init () {
    var state: States = .onboarding

    if (UserDefaults.standard.bool(forKey: UserDefaultKeys.completedOnboarding)) {
      state = .dashboard
    }

    self.state = state
    self.path.append(state)
  }

  func push (state: States) {
    self.state = state
    self.path.append(state)
  }

  func completeOnboarding () {
    UserDefaults.standard.set(true, forKey: UserDefaultKeys.completedOnboarding)

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
    }
    .environmentObject(coordinator)
  }
}

#Preview {
  RootView()
}
