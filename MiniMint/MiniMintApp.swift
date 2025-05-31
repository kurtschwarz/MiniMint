import SwiftUI

@main
struct MiniMintApp: App {
  init () {
    UserDefaults.standard.register(defaults: [
      "completedOnboarding": false
    ])
  }

  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}
