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
      Text("Person")
      Text("\(person?.name ?? "Unknown")")
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
}

#Preview {
  let preview = Preview()

  NavigationStack {
    PersonView(
      person: .init(name: "Test", role: .child),
    )
  }
  .modelContainer(preview.modelContainer)
}
