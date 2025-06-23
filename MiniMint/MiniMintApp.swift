import SwiftUI

// MARK: - AppRoute

enum AppRoute: Hashable {
  case onboarding
  case setup
  case dashboard
}

// MARK: - AppState

final class AppState: ObservableObject {
  @Published var path = NavigationPath()

  func push(route: AppRoute) {
    path.append(route)
  }

  func pop() {
    path.removeLast()
  }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, UIApplicationDelegate {
  static var orientationLock = UIInterfaceOrientationMask.all

  func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
    AppDelegate.orientationLock
  }
}

// MARK: - MiniMintApp

@main
struct MiniMintApp: App {

  // MARK: Lifecycle

  init() {
//    UserDefaults.standard.register(defaults: [
//      "completedOnboarding": false
//    ])
  }

  // MARK: Internal

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      NavigationStack(path: $appState.path) {
        ZStack {
          OnboardingView()
        }
        .navigationDestination(for: AppRoute.self) { route in
          view(route: route)
        }
      }
      .accentColor(Color("primary_green"))
      .environmentObject(appState)
    }
  }

  @ViewBuilder
  func view(route: AppRoute) -> some View {
    switch route {
    case .onboarding:
      OnboardingView()
    case .setup:
      SetupView()
    case .dashboard:
      DashboardView()
    }
  }

  // MARK: Private

  @StateObject private var appState = AppState()
}
