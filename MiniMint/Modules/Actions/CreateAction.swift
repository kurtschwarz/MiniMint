import SwiftData
import SwiftUI

struct CreateActionView: View {

  // MARK: Lifecycle

  init(
    actionGroups: [ActionGroup]? = nil,
    personId: PersistentIdentifier? = nil,
    person: Person? = nil,
  ) {
    _actionGroups = State(initialValue: actionGroups)
    _personId = State(initialValue: personId)
    _person = State(initialValue: person)
  }

  // MARK: Internal

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Details")) {
          TextField("Action Name", text: $action.name)
            .keyboardType(.asciiCapable)

          HStack {
            Text("Deposit Amount")

            TextField(
              "Deposit Amount",
              value: $action.amount,
              format: .number.grouping(.automatic)
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
          }
        }

        Section(header: Text("Group")) {
          Picker("Group", selection: $selectedActionGroup) {
            ForEach(actionGroups ?? []) { group in
              Text(group.name).tag(Optional(group.persistentModelID))
            }
          }

          Button {
            isAddingGroup = true
          } label: {
            Label("New Group", systemImage: "plus")
          }
        }

        if person != nil {
          Section(
            header: Text("Sharing"),
            footer: Text("Actions are avaliable to all members of your family by default. If you'd like to only show this action for \(person!.name) you can do so with the toggle above.")
              .font(.caption)
              .foregroundColor(.gray)
          ) {
            Toggle("Only for \(person!.name)", isOn: $onlyForThisPerson)
          }
        }

        Button(
          action: {
            saveAction()
          },
          label: {
            Text("Save Changes")
          },
        )
      }
      .navigationTitle("Create Action")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(
            action: {
              dismiss()
            },
            label: {
              Image(systemName: "xmark")
            }
          )
          .accessibilityLabel("Cancel")
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(
            action: {
              saveAction()
            },
            label: {
              Image(systemName: "checkmark")
            }
          )
          .accessibilityLabel("Save")
        }
      }
      .listStyle(.plain)
      .alert("New Group", isPresented: $isAddingGroup) {
        TextField("Group Name", text: $newGroupName)
          .keyboardType(.asciiCapable)

        Button("Cancel", role: .cancel) {
          newGroupName = ""
        }

        Button("Create") {
          createGroup()
        }
      } message: {
        Text("Name a new group to organize your actions.")
      }
    }
    .onAppear(perform: getPerson)
    .onAppear(perform: getActionGroups)
  }

  // MARK: Private

  @State private var action = Action(name: "", type: .deposit)
  @State private var actionGroups: [ActionGroup]? = nil
  @State private var selectedActionGroup: PersistentIdentifier? = nil
  @State private var onlyForThisPerson = false

  @State private var isAddingGroup = false
  @State private var newGroupName = ""

  @State private var personId: PersistentIdentifier? = nil
  @State private var person: Person? = nil

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(StateManager.self) private var stateManager: StateManager

  private func saveAction() {
    do {
      action.family = stateManager.family
      action.group = (actionGroups ?? []).first {
        $0.persistentModelID == selectedActionGroup
      } ?? actionGroups?.first

      modelContext.insert(action)
      try modelContext.save()
    } catch {
      return
    }

    dismiss()
  }

  private func createGroup() {
    let trimmed = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
    newGroupName = ""

    guard !trimmed.isEmpty, let family = stateManager.family else {
      return
    }

    let group = ActionGroup(name: trimmed, family: family)
    modelContext.insert(group)

    do {
      try modelContext.save()
    } catch {
      return
    }

    actionGroups = (actionGroups ?? []) + [group]
    selectedActionGroup = group.persistentModelID
  }

  private func getPerson() {
    guard let personId = personId else {
      return
    }

    if person == nil {
      person = modelContext.model(for: personId) as? Person
    }
  }

  private func getActionGroups() {
    guard let familyId = stateManager.familyId else {
      return
    }

    if actionGroups == nil {
      var descriptor = FetchDescriptor<ActionGroup>(
        predicate: #Predicate { group in
          if let family = group.family {
            return family.persistentModelID == familyId
          } else {
            return false
          }
        })

      descriptor.relationshipKeyPathsForPrefetching = [
        \.family,
      ]

      actionGroups = try! modelContext
        .fetch(descriptor)
    }

    if selectedActionGroup == nil {
      selectedActionGroup = actionGroups?.first?.persistentModelID
    }
  }

}

#Preview {
  let preview = Preview()

  NavigationStack { }
    .sheet(isPresented: .constant(true)) {
      CreateActionView(
        actionGroups: ActionGroup.generateDefaults(),
        person: .init(name: "Oskar", role: .child)
      )
      .presentationDetents([.medium, .large], selection: .constant(.large))
    }
    .environment(preview.stateManager)
    .modelContainer(preview.modelContainer)
}
