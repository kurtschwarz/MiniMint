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

    _activePage = State(initialValue: "Activity")
  }

  // MARK: Internal

  @State var person: Person? = nil
  @State var activePage: String? = nil

  var personId: PersistentIdentifier? = nil

  var activityView = PersonView.ActivityView()
  var actionsView = PersonView.ActionsView()
  var rewardsView = PersonView.RewardsView()

  var body: some View {
    MintyUI.ScrollingPageView(
      tint: (person?.avatar != nil
        ? Color(hex: person!.avatar!.background!)
        : .accentColor
      ),
      activePage: $activePage,
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
                .selectAvatar(person!.avatar!.persistentModelID),
                .large
              )
            )
          }
        }

        Text("\(person?.name ?? "Unknown")")
          .font(.system(size: 22, weight: .bold))
          .padding(.top, 10)
      }
      .frame(maxWidth: .infinity, alignment: .center)
      .padding(.top, 5)
      .padding(.bottom, 20)
      .padding(.horizontal, 10)
    } labels: {
      activityView.pageLabel()
      actionsView.pageLabel()
      rewardsView.pageLabel()
    } pages: {
      activityView
      actionsView
      rewardsView
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
    .safeAreaInset(edge: .bottom, content: {
      if activePage == "Activity" {
        activityView.stickyBottomView(navigate: navigate)
      } else if activePage == "Actions" {
        actionsView.stickyBottomView(
          personId: personId!,
          navigate: navigate,
        )
      } else if activePage == "Rewards" {
        rewardsView.stickyBottomView(navigate: navigate)
      }
    })
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
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
