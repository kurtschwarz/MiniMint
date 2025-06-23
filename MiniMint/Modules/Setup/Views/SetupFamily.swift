import SwiftUI

struct SetupFamilyView: View {
  @EnvironmentObject private var setupState: SetupState

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

      TextField("", text: $setupState.familyName, prompt: Text("Family Name"))
        .padding()
        .foregroundStyle(Color.black)
        .background(Color.gray.opacity(0.1))
        .disableAutocorrection(true)

      Button(
        action: {
          setupState.randomizeFamilyName()
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
  SetupFamilyView()
    .environmentObject(SetupState())
}
