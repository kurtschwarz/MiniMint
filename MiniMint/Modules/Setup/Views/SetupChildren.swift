import SwiftUI

struct SetupChildrenView: View {
  @EnvironmentObject private var setupState: SetupState

  var body: some View {
    VStack {
      Text("Add your children")
        .font(.system(size: 20, weight: .bold))
        .foregroundStyle(Color("primary_green"))
        .padding(.top, 30)
        .padding(.bottom, 2)
      
      Text("You can add/remove children later.")
        .font(.system(size: 16, weight: .regular))
        .foregroundStyle(Color("primary_green"))
        .padding(.bottom, 30)

      LazyVGrid (
        columns: [
          GridItem(.flexible(), spacing: 10),
          GridItem(.fixed(28)),
        ],
        alignment: .trailing,
        content: {
          ForEach(self.$setupState.children, id: \.id, content: { $child in
            TextField(
              "",
              text: $child.value,
              prompt: Text("Child's name")
            )
            .padding()
            .foregroundStyle(Color.black)
            .background(Color.gray.opacity(0.1))
            .disableAutocorrection(true)

            Button(
              action: {
                guard let index = self.setupState.children.firstIndex(
                  where: { $0.id == child.id },
                ) else {
                  return
                }
                
                self.setupState.children.remove(at: index)
              },
              label: { Label("", systemImage: "minus.circle.fill") },
            )
            .disabled(self.setupState.children.count <= 1)
            .accentColor(Color.red)
          })
        },
      )

      Button(action: {
        self.setupState.children.append(.init(""))
      }, label: {
        Text("Add another").frame(maxWidth: .infinity)
      })
      .controlSize(.large)
      .buttonStyle(.borderedProminent)
      .accentColor(Color.gray)
      .disabled(self.setupState.children.count > 4)
    }
  }
}

#Preview {
  SetupChildrenView()
    .environmentObject(SetupState())
}
