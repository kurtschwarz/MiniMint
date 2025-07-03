import SwiftUI

struct SetupCurrencyView: View {

  @State var setupCoordinator: SetupCoordinator

  var body: some View {
    VStack {
      Image("setup_currency_image")
        .padding(.top, -60)

      Text("Mint a new currency.")
        .font(.system(size: 20, weight: .bold))
        .foregroundStyle(Color("primary_green"))
        .padding(.top, 30)
        .padding(.bottom, 2)

      Text("It’s easier for kids to remember and get excited about managing their “coins” or “buckaroos”. Use a name that is playful and relatable for your family.")
        .font(.system(size: 16, weight: .regular))
        .foregroundStyle(Color("primary_green"))
        .padding(.bottom, 30)
        .lineSpacing(6)

      TextField("", text: $setupCoordinator.currency.name, prompt: Text("Currency Name"))
        .padding()
        .foregroundStyle(Color.black)
        .background(Color.gray.opacity(0.1))
        .disableAutocorrection(true)
        .keyboardType(.asciiCapable)

      Button(
        action: {
          setupCoordinator.currency.name = Currency.generateName()
        },
        label: {
          Label("Generate with AI", systemImage: "apple.intelligence").frame(maxWidth: .infinity)
        },
      )
      .controlSize(.large)
      .buttonStyle(.borderedProminent)
      .accentColor(Color.gray)
    }
  }

}

#Preview {
  let preview = Preview()

  SetupCurrencyView(
    setupCoordinator: SetupCoordinator(
      modelContext: preview.modelContainer.mainContext,
    ),
  )
}
