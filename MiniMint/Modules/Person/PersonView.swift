import SwiftData
import SwiftUI

struct PersonView: View {

  // MARK: Lifecycle

  init(id: PersistentIdentifier? = nil, person: Person? = nil) {
    self.id = id
    self.person = person
  }

  // MARK: Internal

  @State var person: Person? = nil

  var id: PersistentIdentifier? = nil

  var body: some View {
    VStack {
      if person?.avatar != nil {
        CircleAvatar(
          avatar: (person?.avatar)!,
          size: .large,
        )
        .onTapGesture {
          navigate(.sheet(.editAvatar(person!.avatar!.persistentModelID)))
        }
      }

      Text("\(person?.name ?? "Unknown")")
        .font(.system(size: 24, weight: .bold))
    }
    .onAppear(perform: loadPerson)
  }

  func loadPerson() {
    if id != nil && person == nil {
      person = modelContext.model(for: id!) as? Person
    }
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext
  @Environment(\.navigate) private var navigate
}

#Preview {
  let preview = Preview()

  NavigationStack {
    PersonView(
      id: preview.family.people.first?.persistentModelID,
    )
  }
  .modelContainer(preview.modelContainer)
}
