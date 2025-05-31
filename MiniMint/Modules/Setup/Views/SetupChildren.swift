import SwiftUI

struct SetupChildrenView: View {
  @EnvironmentObject private var coordinator: SetupCoordinator
  @EnvironmentObject private var rootCoordinator: RootCoordinator

  var body: some View {
    VStack {
      Spacer()

      Text("Setup Children")

      Spacer()

      Button(action: {
        self.rootCoordinator.completeOnboarding()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.rootCoordinator.dismissSheet()
        }
      }, label: {
        Text("Complete")
          .frame(maxWidth: .infinity)
      })
      .tint(Color("primary_green"))
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
    }
    .padding(.vertical, 20)
    .padding(.horizontal, 20)
    .navigationBarBackButtonHidden(false)
  }
}

#Preview {
  SetupChildrenView()
    .environmentObject(SetupCoordinator())
}
