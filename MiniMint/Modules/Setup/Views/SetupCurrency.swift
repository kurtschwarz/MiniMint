import SwiftUI

struct SetupCurrencyView: View {
  @EnvironmentObject private var coordinator: SetupCoordinator

  var body: some View {
    VStack {
      Spacer()

      Text("Setup Currency")

      Spacer()

      Button(action: {
        self.coordinator.next()
      }, label: {
        Text("Next")
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
  SetupCurrencyView()
    .environmentObject(SetupCoordinator())
}
