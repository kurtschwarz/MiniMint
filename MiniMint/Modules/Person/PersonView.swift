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
    MintyUI.ScrollingPageView(
      tint: (person?.avatar != nil
        ? Color(hex: person!.avatar!.background!)
        : .accentColor
      ),
    ) {
      VStack(alignment: .center) {
        if person?.avatar != nil {
          MintyUI.CircleAvatar(
            avatar: (person?.avatar)!,
            size: .large,
          )
          .onTapGesture {
            navigate(
              .sheet(
                .selectAvatar(person!.avatar!.persistentModelID)
              )
            )
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
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(
          action: {
            dismiss()
          },
        ) {
          HStack {
            Image(systemName: "chevron.left")
              .scaleEffect(0.60)
              .font(Font.title.weight(.semibold))

            Text("Back")
              .offset(x: -12)
          }
        }
        .offset(x: -7)
        .tint(toolbarTintColor)
      }
    }
    .navigationBarBackButtonHidden(true)
    .onAppear(perform: loadPerson)
  }

  func loadPerson() {
    if personId != nil && person == nil {
      person = modelContext.model(for: personId!) as? Person
    }

    if person?.avatar?.background != nil {
      toolbarTintColor = Color(hex: (person?.avatar?.background)!)
        .adjust(saturation: 0.30, brightness: -0.35)
    }
  }

  // MARK: Private

  @State private var toolbarTintColor = Color.primaryGreen

  @Environment(\.modelContext) private var modelContext
  @Environment(\.navigate) private var navigate
  @Environment(\.dismiss) private var dismiss
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
