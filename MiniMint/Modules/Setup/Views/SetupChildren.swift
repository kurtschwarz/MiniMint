import SwiftUI

struct SetupChildrenView: View {

  @State var setupCoordinator: SetupCoordinator

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

      LazyVGrid(
        columns: [
          GridItem(.flexible(), spacing: 10),
          GridItem(.fixed(28)),
        ],
        alignment: .trailing,
        content: {
          ForEach($setupCoordinator.people, id: \.persistentModelID, content: { $person in
            TextField(
              "",
              text: $person.name,
              prompt: Text("Child's name"),
            )
            .padding()
            .foregroundStyle(Color.black)
            .background(Color.gray.opacity(0.1))
            .disableAutocorrection(true)

            Button(
              action: {
                guard let index = setupCoordinator.people.firstIndex(
                  where: { $0.persistentModelID == person.persistentModelID },
                ) else {
                  return
                }

                setupCoordinator.people.remove(at: index)
              },
              label: { Label("", systemImage: "minus.circle.fill") },
            )
            .disabled(setupCoordinator.people.count <= 1)
            .accentColor(Color.red)
          })
        },
      )

      Button(action: {
        setupCoordinator.people.append(.init(name: "", role: .child))
      }, label: {
        Text("Add another").frame(maxWidth: .infinity)
      })
      .controlSize(.large)
      .buttonStyle(.borderedProminent)
      .accentColor(Color.gray)
      .disabled(setupCoordinator.people.count > 4)
    }
  }

}

#Preview {
  let preview = Preview()

  SetupChildrenView(
    setupCoordinator: SetupCoordinator(
      modelContext: preview.modelContainer.mainContext,
    )
  )
}
