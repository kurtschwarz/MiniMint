import SwiftData
import SwiftUI

// MARK: - SetupView

struct SetupView: View {

  // MARK: Lifecycle

  init() {
    setupCoordinator = SetupCoordinator()
  }

  // MARK: Internal

  var body: some View {
    ZStack {
      Image("background_tile")
        .resizable(resizingMode: .tile)
        .ignoresSafeArea(.all)

      VStack {
        Spacer()

        VStack(alignment: .center) {
          setupCoordinator.currentStepView()
            .environment(stateManager)
            .environment(setupCoordinator)

          Button(
            action: {
              setupCoordinator.nextStep()
            },
            label: {
              Text(setupCoordinator.currentStep.nextButtonLabel)
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
            setupCoordinator.previousStep()
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
    .onAppear {
      setupCoordinator.stateManager = stateManager
      setupCoordinator.modelContext = modelContext
    }
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext: ModelContext
  @Environment(StateManager.self) private var stateManager: StateManager

  @State private var setupCoordinator: SetupCoordinator
}

#Preview {
  let preview = Preview()

  NavigationStack {
    SetupView()
  }
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
