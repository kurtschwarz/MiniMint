import SwiftUI

struct OnboardingView: View {

  // MARK: Internal

  var body: some View {
    ZStack {
      Color("background_primary")
        .ignoresSafeArea(.all)

      VStack {
        OnboardingCarousel()
          .frame(maxHeight: .infinity)

        Button(
          action: {
            navigate(.push(.setup))
          },
          label: {
            Text("Get Started")
              .frame(maxWidth: .infinity)
          },
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
      .accentColor(Color("primary_green"))
    }
  }

  // MARK: Private

  @Environment(\.navigate) private var navigate
}

#Preview {
  NavigationStack {
    OnboardingView()
  }
}
