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

  var rewardsView = PersonView.RewardsView()

  var activityView: PersonView.ActivityView {
    PersonView.ActivityView(personId: personId)
  }

  var actionsView: PersonView.ActionsView {
    PersonView.ActionsView(personId: personId)
  }

  var body: some View {
    MintyUI.ScrollingPageView(
      tint: (
        person?.avatar != nil
          ? Color(hex: person!.avatar!.background!)
          : .accentColor,
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
                .large,
              ),
            )
          }
        }

        if let person {
          TextField("Name", text: Binding(
            get: { person.name },
            set: { person.name = $0 },
          ))
          .font(.system(size: 22, weight: .bold))
          .multilineTextAlignment(.center)
          .keyboardType(.asciiCapable)
          .disableAutocorrection(true)
          .submitLabel(.done)
          .focused($isEditingName)
          .onSubmit(commitName)
          .padding(.top, 10)
        } else {
          Text("Unknown")
            .font(.system(size: 22, weight: .bold))
            .padding(.top, 10)
        }
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
          Image(systemName: "chevron.left")
        }
        .tint(toolbarTintColor)
        .accessibilityLabel("Back")
      }
    }
    .navigationBarBackButtonHidden(true)
    .onAppear(perform: loadPerson)
    .onChange(of: isEditingName) { _, editing in
      if !editing {
        commitName()
      }
    }
    .onChange(of: person?.avatar?.background) { _, newValue in
      if newValue != nil {
        toolbarTintColor = Color(hex: newValue!)
          .adjust(saturation: 0.30, brightness: -0.35)
      }
    }
    // Recording an action drops the adult back on the Activity tab to see it.
    .onChange(of: stateManager.recordedActionCount) {
      withAnimation(.easeInOut(duration: 0.25)) {
        activePage = "Activity"
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
    if personId != nil, person == nil {
      person = modelContext.model(for: personId!) as? Person
    }

    committedName = person?.name ?? ""
  }

  /// Trim and persist the edited name, restoring the last committed value when
  /// the field is left empty.
  func commitName() {
    guard let person else {
      return
    }

    let trimmed = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      person.name = committedName
      return
    }

    person.name = trimmed
    committedName = trimmed

    try? modelContext.save()
  }

  // MARK: Private

  @State private var toolbarTintColor = Color.primaryGreen
  @State private var committedName = ""

  @FocusState private var isEditingName: Bool

  @Environment(\.modelContext) private var modelContext
  @Environment(\.navigate) private var navigate
  @Environment(\.dismiss) private var dismiss
  @Environment(StateManager.self) private var stateManager: StateManager
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
