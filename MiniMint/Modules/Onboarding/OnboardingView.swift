import SwiftUI

struct OnboardingView: View {
  @EnvironmentObject private var coordinator: RootCoordinator

  var body: some View {
    ZStack {
      Color("background_primary")
        .ignoresSafeArea(.all)

      VStack {
        OnboardingCarousel()
          .frame(maxHeight: .infinity)

        Button(
          action: {
            self.coordinator.completeOnboarding()
          },
          label: {
            Text("Get Started")
              .frame(maxWidth: .infinity)
          }
        )
        .tint(Color("primary_green"))
        .controlSize(.large)
        .buttonStyle(.borderedProminent)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 20)
      .navigationBarTitle("")
      .navigationBarBackButtonHidden(true)
      .navigationBarHidden(true)
    }
  }
}

#Preview {
  OnboardingView()
    .environmentObject(RootCoordinator())
}
