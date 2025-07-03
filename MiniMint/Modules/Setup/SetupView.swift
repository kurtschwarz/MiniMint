import SwiftData
import SwiftUI

// MARK: - SetupStep

enum SetupStep: Hashable {
  case setupFamily
  case setupCurrency
  case setupChildren
}

// MARK: - SetupChildName

struct SetupChildName: Identifiable {

  // MARK: Lifecycle

  init(_ value: String) {
    self.value = value
  }

  // MARK: Internal

  let id = UUID()
  var value: String
}

// MARK: - SetupState

final class SetupState: ObservableObject {

  // MARK: Lifecycle

  init() {
    familyName = family.name
    currencyName = currency.name
  }

  // MARK: Internal

  @Published var step = SetupStep.setupFamily

  @Published var familyName = ""
  @Published var currencyName = ""
  @Published var children: [SetupChildName] = [.init("")]

  @Published var randomFamilyNames: [String] = []
  @Published var randomCurrencyNames: [String] = []

  var family = Family()
  var currency = Currency()

  @ViewBuilder
  func view(step: SetupStep) -> some View {
    switch step {
    case .setupFamily:
      SetupFamilyView()
    case .setupCurrency:
      SetupCurrencyView()
    case .setupChildren:
      SetupChildrenView()
    }
  }

  func next() {
    switch step {
    case .setupFamily:
      step = .setupCurrency

    case .setupCurrency:
      step = .setupChildren

    case .setupChildren:
      step = .setupFamily
    }
  }

  func previous() {
    switch step {
    case .setupFamily:
      return
    case .setupCurrency:
      step = .setupFamily
    case .setupChildren:
      step = .setupCurrency
    }
  }

  func randomizeFamilyName() {
    familyName = Family.generateName()
  }

  func randomizeCurrencyName() {
    currencyName = Currency.generateName()
  }
}

// MARK: - SetupView

struct SetupView: View {

  // MARK: Internal

  var body: some View {
    ZStack {
      Image("background_tile")
        .resizable(resizingMode: .tile)
        .ignoresSafeArea(.all)

      VStack {
        Spacer()

        VStack(alignment: .center) {
          setupState.view(step: setupState.step)
            .environment(stateManager)
            .environmentObject(setupState)

          Button(
            action: {
              if setupState.step == .setupChildren {
                modelContext.insert(setupState.family)
                try? modelContext.save()

                stateManager.family = setupState.family
                stateManager.familyId = setupState.family.persistentModelID

                navigate(.push(.home))
              } else {
                setupState.next()
              }
            },
            label: {
              Text(setupState.step == .setupChildren ? "Complete" : "Next")
                .frame(maxWidth: .infinity)
            },
          )
          .tint(Color("primary_green"))
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
          UnevenRoundedRectangle(
            cornerRadii: .init(topLeading: 40, topTrailing: 40),
          )
          .fill(Color.white)
          .edgesIgnoringSafeArea(.bottom)
          .shadow(radius: 60),
        )
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(
          action: {
            if setupState.step == .setupFamily {
              navigate(.back)
            } else {
              setupState.previous()
            }
          },
        ) {
          HStack {
            Image(systemName: "chevron.left")
              .scaleEffect(0.60)
              .font(Font.title.weight(.semibold))

            Text("Back")
              .offset(x: -12)
          }
        }
        .offset(x: -7)
        .accentColor(Color("primary_green"))
      }
    }
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @Environment(\.navigate) private var navigate
  @Environment(StateManager.self) private var stateManager: StateManager
  @Environment(\.modelContext) private var modelContext: ModelContext
  @StateObject private var setupState = SetupState()
}

#Preview {
  let preview = Preview()

  NavigationStack {
    SetupView()
  }
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
