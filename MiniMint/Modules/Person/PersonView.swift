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
          .padding(.top, 10)
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.top, 10)
      .padding(.bottom, 30)
      .padding(.horizontal, 10)
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
    .onChange(of: person?.avatar?.background) { _, newValue in
      if newValue != nil {
        toolbarTintColor = Color(hex: newValue!)
          .adjust(saturation: 0.30, brightness: -0.35)
      }
    }
  }

  func loadPerson() {
    if personId != nil && person == nil {
      person = modelContext.model(for: personId!) as? Person
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
