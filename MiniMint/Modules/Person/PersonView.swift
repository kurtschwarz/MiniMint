import SwiftData
import SwiftUI

struct PersonView: View {

  // MARK: Lifecycle

  init(
    personId: PersistentIdentifier? = nil,
    person: Person? = nil,
  ) {
    self.personId = personId
    self.person = person
  }

  // MARK: Internal

  @State var person: Person? = nil

  var personId: PersistentIdentifier? = nil

  var body: some View {
    VStack(alignment: .center) {
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

      Spacer()
    }
    .onAppear(perform: loadPerson)
  }

  func loadPerson() {
    if personId != nil && person == nil {
      person = modelContext.model(for: personId!) as? Person
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
      personId: preview.family.people.first?.persistentModelID,
    )
  }
  .modelContainer(preview.modelContainer)
}
