import SwiftData
import SwiftUI

struct SetupChildrenView: View {

  @State var setupCoordinator: SetupCoordinator

  @FocusState private var focusedPerson: PersistentIdentifier?

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
          ForEach(setupCoordinator.people, id: \.persistentModelID, content: { person in
            TextField(
              "",
              text: nameBinding(for: person),
              prompt: Text("Child's name"),
            )
            .padding()
            .foregroundStyle(Color.black)
            .background(Color.gray.opacity(0.1))
            .disableAutocorrection(true)
            .focused($focusedPerson, equals: person.persistentModelID)

            Button(
              action: { remove(person) },
              label: { Label("", systemImage: "minus.circle.fill") },
            )
            .disabled(setupCoordinator.people.count <= 1)
            .accentColor(Color.red)
          })
        },
      )

      Button(action: {
        let person = Person(
          name: "",
          role: .child,
          avatar: Avatar.generate(),
        )
        setupCoordinator.people.append(person)
        focusedPerson = person.persistentModelID
      }, label: {
        Text("Add another").frame(maxWidth: .infinity)
      })
      .controlSize(.large)
      .buttonStyle(.borderedProminent)
      .accentColor(Color.gray)
      .disabled(setupCoordinator.people.count > 4)
    }
    .onAppear {
      focusedPerson = setupCoordinator.people.first?.persistentModelID
    }
  }

  private func nameBinding(for person: Person) -> Binding<String> {
    Binding(
      get: { person.name },
      set: { person.name = $0 },
    )
  }

  private func remove(_ person: Person) {
    guard let index = setupCoordinator.people.firstIndex(
      where: { $0.persistentModelID == person.persistentModelID },
    ) else {
      return
    }

    let wasFocused = focusedPerson == person.persistentModelID

    setupCoordinator.people.remove(at: index)

    if wasFocused {
      let neighborIndex = max(0, index - 1)
      focusedPerson = setupCoordinator.people.indices.contains(neighborIndex)
        ? setupCoordinator.people[neighborIndex].persistentModelID
        : nil
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
