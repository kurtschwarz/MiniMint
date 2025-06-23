import SwiftUI

enum AppRoute: Hashable {
  case onboarding
  case setup
  case dashboard
}

final class AppState: ObservableObject {
  @Published var path = NavigationPath()

  func push (route: AppRoute) {
    self.path.append(route)
  }
  
  func pop () {
    self.path.removeLast()
  }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
  static var orientationLock = UIInterfaceOrientationMask.all

  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return AppDelegate.orientationLock
  }
}

@main
struct MiniMintApp: App {
  @StateObject private var appState = AppState()
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  init () {
//    UserDefaults.standard.register(defaults: [
//      "completedOnboarding": false
//    ])
  }

  @ViewBuilder
  func view (route: AppRoute) -> some View {
    switch route {
    case .onboarding:
      OnboardingView()
    case .setup:
      SetupView()
    case .dashboard:
      DashboardView()
    }
  }

  var body: some Scene {
    WindowGroup {
      NavigationStack(path: $appState.path) {
        ZStack {
          OnboardingView()
        }
          .navigationDestination(for: AppRoute.self) { route in
            self.view(route: route)
          }
      }
      .accentColor(Color("primary_green"))
      .environmentObject(self.appState)
    }
  }
}
