import SwiftData
import SwiftUI

struct ScheduledActionsView: View {

  // MARK: Lifecycle

  init(person: Person) {
    self.person = person
  }

  // MARK: Internal

  var body: some View {
    NavigationStack {
      Group {
        if person.scheduledActions.isEmpty {
          ContentUnavailableView(
            "No Schedules",
            systemImage: "calendar.badge.clock",
            description: Text("Schedule actions to repeat automatically."),
          )
        } else {
          List {
            ForEach(person.scheduledActions) { schedule in
              NavigationLink {
                CreateScheduledActionView(person: person, schedule: schedule)
              } label: {
                scheduleRow(schedule)
              }
            }
            .onDelete(perform: delete)
          }
          .listStyle(.plain)
        }
      }
      .navigationTitle("Schedules")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
          .accessibilityLabel("Close")
        }

        ToolbarItem(placement: .confirmationAction) {
          Button {
            isCreating = true
          } label: {
            Image(systemName: "plus")
          }
          .accessibilityLabel("New Schedule")
        }
      }
      .navigationDestination(isPresented: $isCreating) {
        CreateScheduledActionView(person: person)
      }
    }
  }

  // MARK: Private

  private let person: Person

  @State private var isCreating = false

  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext

  @ViewBuilder
  private func scheduleRow(_ schedule: ScheduledAction) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(schedule.name)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(schedule.isActive ? Color.primary : Color.secondary)

        Spacer()

        if !schedule.isActive {
          Text("Paused")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(.quaternary, in: Capsule())
        }
      }

      HStack(spacing: 4) {
        if let action = schedule.action {
          Text(action.name)
        }

        Text("·")

        if schedule.scheduleFrequency == .recurring {
          Text("Every \(schedule.intervalDays) day\(schedule.intervalDays == 1 ? "" : "s")")
        } else {
          Text("Once")
        }
      }
      .font(.system(size: 13))
      .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }

  private func delete(at offsets: IndexSet) {
    for index in offsets {
      let schedule = person.scheduledActions[index]
      modelContext.delete(schedule)
    }
    try? modelContext.save()
  }

}
