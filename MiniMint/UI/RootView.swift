import SwiftUI

enum States: Hashable {
  case onboarding
}

class RootCoordinator: ObservableObject {
  @Published var path: NavigationPath = NavigationPath()
  @Published var state: States = .onboarding

  @ViewBuilder
  func build (state: States) -> some View {
    switch state {
    case .onboarding:
      OnboardingView()
    }
  }

  init () {}
}

struct RootView: View {
  @StateObject private var coordinator = RootCoordinator()

  var body: some View {
    NavigationStack(path: $coordinator.path) {
      coordinator.build(state: .onboarding)
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
