import SwiftData
import SwiftUI

struct CreatePersonView: View {

  // MARK: Lifecycle

  init(role: Role = .child) {
    _person = State(initialValue: Person(name: "", role: role, avatar: Avatar.generate()))
  }

  // MARK: Internal

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Details")) {
          TextField("Name", text: $person.name)
            .keyboardType(.asciiCapable)
            .disableAutocorrection(true)
        }

        Button(
          action: { savePerson() },
          label: { Text("Save Changes") },
        )
        .disabled(!canSave)
      }
      .listStyle(.plain)
      .navigationTitle(person.role == .child ? "Add Little" : "Add Adult")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(
            action: { dismiss() },
            label: { Image(systemName: "xmark") },
          )
          .accessibilityLabel("Cancel")
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(
            action: { savePerson() },
            label: { Image(systemName: "checkmark") },
          )
          .disabled(!canSave)
          .accessibilityLabel("Save")
        }
      }
    }
  }

  // MARK: Private

  @State private var person: Person

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(StateManager.self) private var stateManager: StateManager

  private var canSave: Bool {
    !person.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  private func savePerson() {
    let name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !name.isEmpty, let family = stateManager.family else {
      return
    }

    person.name = name
    person.sortOrder = nextSortOrder(for: person.role, in: family)

    do {
      modelContext.insert(person)
      // Append to the relationship directly (rather than setting `person.family`)
      // so the change to `family.people` is observed and the crew list refreshes
      // immediately instead of only after a relaunch.
      family.people.append(person)
      try modelContext.save()
    } catch {
      return
    }

    dismiss()
  }

  /// Append after the last person already in that role's list.
  private func nextSortOrder(for role: Role, in family: Family) -> Int {
    (family.people.filter { $0.role == role }.map(\.sortOrder).max() ?? -1) + 1
  }

}

#Preview {
  let preview = Preview()

  NavigationStack { }
    .sheet(isPresented: .constant(true)) {
      CreatePersonView(role: .child)
        .presentationDetents([.medium, .large], selection: .constant(.medium))
    }
    .environment(preview.stateManager)
    .modelContainer(preview.modelContainer)
}
