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
    let tint = (person?.avatar != nil ? Color(hex: person!.avatar!.background!) : .accentColor)

    MintyUI.ScrollingPageView(
      accentColor: tint,
    ) {
      VStack(alignment: .center) {
        if person?.avatar != nil {
          CircleAvatar(
            avatar: (person?.avatar)!,
            size: .large,
          )
          .onTapGesture {
            navigate(.sheet(.selectAvatar(person!.avatar!.persistentModelID)))
          }
        }

        Text("\(person?.name ?? "Unknown")")
          .font(.system(size: 24, weight: .bold))
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.vertical, 40)
      .padding(.horizontal, 20)
    } labels: {
      MintyUI.PageLabel(title: "Activity")
      MintyUI.PageLabel(title: "Actions")
      MintyUI.PageLabel(title: "Rewards")
    } pages: {
      Text("Activity View")
      Text("Actions View")
      Text("Rewards View")
    }
    .onAppear(perform: loadPerson)
  }

  func loadPerson() {
    if personId != nil && person == nil {
      person = modelContext.model(for: personId!) as? Person
    }

    accentColor(
      Color(hex: (person?.avatar?.background)!)
        .adjust(saturation: 0.30, brightness: -0.35)
    )
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext
  @Environment(\.navigate) private var navigate
  @Environment(\.accentColor) private var accentColor
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
