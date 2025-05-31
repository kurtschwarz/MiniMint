import SwiftUI

enum Steps: Hashable {
  case setupFamily
  case setupCurrency
  case setupChildren
}

class SetupCoordinator: ObservableObject {
  @EnvironmentObject private var rootCoordinator: RootCoordinator

  @Published var history: [Steps] = []

  @State var familyName: String = ""
  @State var currencyName: String = ""
  @State var childrenNames: [String] = []

  private var steps: [Steps] = [
    .setupFamily,
    .setupChildren,
    .setupCurrency,
  ]

  func next () {
    var next: Steps?
    let current = self.history.last ?? .setupFamily
    switch current {
    case .setupFamily:
      next = .setupCurrency
    case .setupCurrency:
      next = .setupChildren
    case .setupChildren:
      next = nil
    }

    if (next != nil) {
      self.history.append(next!)
    }
  }

  func complete () {
    if (self.rootCoordinator.state == .onboarding) {
      self.rootCoordinator.completeOnboarding()
    }
  }
}

struct SetupView: View {
  var afterCompletion: (() -> Void)?

  @StateObject private var coordinator = SetupCoordinator()
  @EnvironmentObject private var rootCoordinator: RootCoordinator

  var body: some View {
    NavigationStack (path: $coordinator.history) {
      SetupFamilyView()
        .navigationDestination(for: Steps.self) { step in
          switch step {
          case .setupFamily:
            SetupFamilyView()
          case .setupCurrency:
            SetupCurrencyView()
          case .setupChildren:
            SetupChildrenView()
          }
        }
    }
    .accentColor(Color("primary_green"))
    .environmentObject(self.coordinator)
    .environmentObject(self.rootCoordinator)
    .interactiveDismissDisabled(true)
    .presentationDragIndicator(.hidden)
    .presentationDetents([
      .fraction(0.6),
    ])
  }
}

#Preview {
  SetupView()
    .environmentObject(RootCoordinator())
}
