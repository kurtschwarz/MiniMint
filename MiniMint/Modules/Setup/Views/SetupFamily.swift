import SwiftUI

struct SetupFamilyView: View {

  @State var setupCoordinator: SetupCoordinator

  var body: some View {
    VStack {
      Image("setup_family_banner")
        .padding(.top, -60)

      Text("What should we call your family?")
        .font(.system(size: 20, weight: .bold))
        .foregroundStyle(Color("primary_green"))
        .padding(.top, 30)
        .padding(.bottom, 2)

      Text("You can change this later.")
        .font(.system(size: 16, weight: .regular))
        .foregroundStyle(Color("primary_green"))
        .padding(.bottom, 30)

      TextField("", text: $setupCoordinator.family.name, prompt: Text("Family Name"))
        .padding()
        .foregroundStyle(Color.black)
        .background(Color.gray.opacity(0.1))
        .disableAutocorrection(true)

      Button(
        action: {
          setupCoordinator.family.name = Family.generateName()
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

  SetupFamilyView(
    setupCoordinator: SetupCoordinator(
      modelContext: preview.modelContainer.mainContext,
    )
  )
}
