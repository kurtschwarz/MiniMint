import SwiftData
import SwiftUI

struct CreateScheduledActionView: View {

  // MARK: Lifecycle

  init(person: Person, schedule: ScheduledAction? = nil) {
    self.person = person
    existingSchedule = schedule

    if let schedule {
      _name = State(initialValue: schedule.name)
      _selectedActionId = State(initialValue: schedule.action?.persistentModelID)
      _frequency = State(initialValue: schedule.scheduleFrequency)
      _intervalDays = State(initialValue: schedule.intervalDays)
      _startDate = State(initialValue: schedule.startDate)
      _note = State(initialValue: schedule.note ?? "")
      _isActive = State(initialValue: schedule.isActive)
    }
  }

  // MARK: Internal

  var body: some View {
    Form {
      Section(header: Text("Details")) {
        TextField("Name", text: $name)
          .keyboardType(.asciiCapable)

        Picker("Action", selection: $selectedActionId) {
          Text("Select an action").tag(nil as PersistentIdentifier?)
          ForEach(actions) { action in
            Text(action.name).tag(Optional(action.persistentModelID))
          }
        }
      }

      Section(header: Text("Schedule")) {
        Picker("Frequency", selection: $frequency) {
          Text("Once").tag(ScheduledActionFrequency.once)
          Text("Recurring").tag(ScheduledActionFrequency.recurring)
        }

        if frequency == .recurring {
          Stepper(
            "Every \(intervalDays) day\(intervalDays == 1 ? "" : "s")",
            value: $intervalDays,
            in: 1...365,
          )
        }

        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
      }

      Section(header: Text("Options")) {
        TextField("Note", text: $note)

        if existingSchedule != nil {
          Toggle("Active", isOn: $isActive)
        }
      }

      Button(action: save) {
        Text(existingSchedule != nil ? "Save Changes" : "Create Schedule")
      }
    }
    .navigationTitle(existingSchedule != nil ? "Edit Schedule" : "New Schedule")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button(action: save) {
          Image(systemName: "checkmark")
        }
        .accessibilityLabel("Save")
      }
    }
    .listStyle(.plain)
    .onAppear(perform: loadActions)
  }

  // MARK: Private

  private let person: Person
  private let existingSchedule: ScheduledAction?

  @State private var name = ""
  @State private var selectedActionId: PersistentIdentifier?
  @State private var frequency = ScheduledActionFrequency.once
  @State private var intervalDays = 1
  @State private var startDate = Date.now
  @State private var note = ""
  @State private var isActive = true
  @State private var actions: [Action] = []

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(StateManager.self) private var stateManager: StateManager

  private func save() {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedName.isEmpty, let selectedActionId else { return }
    guard let action = modelContext.model(for: selectedActionId) as? Action else { return }

    let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

    if let existingSchedule {
      existingSchedule.name = trimmedName
      existingSchedule.action = action
      existingSchedule.frequency = frequency.rawValue
      existingSchedule.intervalDays = intervalDays
      existingSchedule.startDate = startDate
      existingSchedule.note = trimmedNote.isEmpty ? nil : trimmedNote
      existingSchedule.isActive = isActive
    } else {
      let schedule = ScheduledAction(
        name: trimmedName,
        action: action,
        person: person,
        family: person.family,
        frequency: frequency,
        intervalDays: intervalDays,
        startDate: startDate,
        note: trimmedNote.isEmpty ? nil : trimmedNote,
      )
      modelContext.insert(schedule)
    }

    try? modelContext.save()
    dismiss()
  }

  private func loadActions() {
    guard let familyId = stateManager.familyId else { return }

    let descriptor = FetchDescriptor<Action>(
      predicate: #Predicate { action in
        if let family = action.family {
          return family.persistentModelID == familyId
        } else {
          return false
        }
      },
    )

    actions = (try? modelContext.fetch(descriptor)) ?? []
  }

}
