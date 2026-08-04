import SwiftData
import SwiftUI

/// Bottom sheet for recording an `Action` against a `Person`. Lets the adult
/// backdate the entry to any past (or the current) day and attach an optional
/// note, then writes a `LedgerEntry` and moves the person's balance.
struct RecordActionView: View {

  // MARK: Lifecycle

  init(actionId: PersistentIdentifier, personId: PersistentIdentifier) {
    self.actionId = actionId
    self.personId = personId
  }

  // MARK: Internal

  var body: some View {
    NavigationStack {
      Form {
        if let action, let person {
          Section {
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text(action.name)
                  .fontWeight(.medium)

                Text(action.actionType == .deposit
                  ? "Earns for \(person.name)"
                  : "Spends from \(person.name)")
                  .font(.caption)
                  .foregroundColor(.gray)
              }

              Spacer()

              MintyUI.CurrencyAmount(action.amount)
            }
          }

          Section(header: Text("When")) {
            DatePicker(
              "Date",
              selection: $date,
              in: ...Date.now,
              displayedComponents: .date,
            )
          }

          Section(header: Text("Note")) {
            TextField("Add a note (optional)", text: $note, axis: .vertical)
              .keyboardType(.default)
              .lineLimit(1 ... 4)
          }

          Button(
            action: {
              record()
            },
            label: {
              Text(action.actionType == .deposit ? "Add to Balance" : "Subtract from Balance")
            },
          )
        } else {
          Text("Action unavailable")
            .foregroundColor(.gray)
        }
      }
      .navigationTitle("Record Action")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(
            action: {
              dismiss()
            },
            label: {
              Image(systemName: "xmark")
            },
          )
          .accessibilityLabel("Cancel")
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(
            action: {
              record()
            },
            label: {
              Image(systemName: "checkmark")
            },
          )
          .accessibilityLabel("Record")
          .disabled(action == nil || person == nil)
        }
      }
      .listStyle(.plain)
    }
    .onAppear(perform: load)
  }

  func load() {
    if action == nil {
      action = modelContext.model(for: actionId) as? Action
    }

    if person == nil {
      person = modelContext.model(for: personId) as? Person
    }
  }

  /// Post the tapped action into the person's wallet and move its balance by
  /// the entry's signed amount.
  func record() {
    guard let action, let person else {
      return
    }

    // Every person gets a wallet at creation, but guard so a legacy person
    // without one still records cleanly.
    let ledger: Ledger
    if let existing = person.ledger {
      ledger = existing
    } else {
      ledger = Ledger(person: person)
      person.ledger = ledger
    }

    let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

    // Snapshot the type and amount now so the entry keeps its value even if the
    // source action is later edited or deleted.
    let entryType: LedgerEntryType = action.actionType == .deposit ? .deposit : .withdrawl

    let entry = LedgerEntry(
      ledger: ledger,
      type: entryType,
      amount: action.amount,
      date: date,
      action: action,
      note: trimmedNote.isEmpty ? nil : trimmedNote,
    )
    modelContext.insert(entry)

    ledger.balance += entry.signedAmount

    do {
      try modelContext.save()
    } catch {
      return
    }

    // Signal screens (e.g. the person view) to jump back to Activity.
    stateManager.recordedActionCount += 1

    dismiss()
  }

  // MARK: Private

  @State private var action: Action? = nil
  @State private var person: Person? = nil
  @State private var date = Date.now
  @State private var note = ""

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(StateManager.self) private var stateManager: StateManager

  private let actionId: PersistentIdentifier
  private let personId: PersistentIdentifier

}

#Preview {
  let preview = Preview()

  let person = preview.family.people.first { $0.role == .child }!
  let action = preview.family.actionGroups.first!.actions.first!

  NavigationStack { }
    .sheet(isPresented: .constant(true)) {
      RecordActionView(
        actionId: action.persistentModelID,
        personId: person.persistentModelID,
      )
      .presentationDetents([.medium, .large], selection: .constant(.medium))
    }
    .environment(preview.stateManager)
    .modelContainer(preview.modelContainer)
}
