import SwiftData
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Internal

  var body: some View {
    ScrollView {
      VStack {
        HStack(alignment: .center, spacing: 16) {
          MintyUI.AvatarGroup(
            people: littles,
          )

          VStack(alignment: .leading, spacing: 0) {
            Text("the")
              .font(.system(size: 14, weight: .medium))
            Text(stateManager.family?.name ?? "")
              .font(.system(size: 28, weight: .bold, design: .serif))
            Text("family")
              .font(.system(size: 14, weight: .medium))
          }
          .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 20)

        summaryCard
          .padding(.bottom, 24)

        Section(
          header: HStack {
            Text("Your Crew")
              .font(.system(size: 16, weight: .bold))
            Spacer()
            if isEditingCrew {
              Button("Done") {
                withAnimation { isEditingCrew = false }
              }
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(Color("primary_green"))
            }
          },
        ) {
          Section(
            header: HStack {
              Text("Littles")
                .font(.system(size: 14, weight: .medium))
              Spacer()
            }.padding(.top, 2),
          ) {
            MintyUI.PeopleList(
              people: littles,
              showAddPersonButton: true,
              addPersonRole: .child,
              isEditing: $isEditingCrew,
            )
            .padding(.bottom, 18)
          }

          Section(
            header: HStack {
              Text("Adults")
                .font(.system(size: 14, weight: .medium))
              Spacer()
            },
          ) {
            MintyUI.PeopleList(
              people: adults,
              showAddPersonButton: true,
              showBalance: false,
              addPersonRole: .parent,
              isEditing: $isEditingCrew,
            )
          }
        }

        recentActivitySection
          .padding(.top, 28)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 20)
    }
    .toolbar(content: {
//      ToolbarItem(placement: .topBarTrailing) {
//        Button(
//          action: { },
//          label: {
//            Image(systemName: "bell.badge")
//              .foregroundStyle(.red, Color("primary_green"))
//          },
//        )
//      }
//
//      ToolbarItem(placement: .topBarTrailing) {
//        Button(
//          action: { },
//          label: {
//            Image(systemName: "person")
//              .foregroundStyle(Color("primary_green"))
//          },
//        )
//      }
    })
    .scrollIndicators(.hidden)
    .scrollDisabled(isEditingCrew)
    .background(Color.white, ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext
  @Environment(StateManager.self) private var stateManager: StateManager

  @State private var isEditingCrew = false

  private var littles: [Person] {
    people(role: .child)
  }

  private var adults: [Person] {
    people(role: .parent)
  }

  /// Currency held across all the Littles — the family's money in play.
  private var totalInCirculation: Int64 {
    littles.reduce(0) { $0 + $1.balance }
  }

  private var currencyName: String {
    stateManager.family?.currency?.name ?? "coins"
  }

  /// The newest ledger entries across the whole family, most recent first.
  private var recentActivity: [ActivityItem] {
    (stateManager.family?.people ?? [])
      .flatMap { person in
        (person.ledger?.entries ?? []).map { ActivityItem(person: person, entry: $0) }
      }
      .sorted { ($0.entry.date ?? .distantPast) > ($1.entry.date ?? .distantPast) }
      .prefix(5)
      .map { $0 }
  }

  /// The family's money at a glance, sitting just under the family header.
  private var summaryCard: some View {
    HStack(spacing: 14) {
      if let avatar = stateManager.family?.currency?.avatar {
        MintyUI.CircleAvatar(avatar: avatar, size: .medium)
      } else {
        Image("coin_icon")
          .resizable()
          .frame(width: 44, height: 44)
      }

      VStack(alignment: .leading, spacing: 2) {
        MintyUI.CurrencyAmount(totalInCirculation, size: 26)
        Text("\(currencyName) in circulation")
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(Color("dark_grey").opacity(0.7))
      }

      Spacer(minLength: 0)
    }
    .padding(16)
    .frame(maxWidth: .infinity)
    .background(Color("light_gray"))
    .cornerRadius(20)
  }

  private var recentActivitySection: some View {
    Section(
      header: HStack {
        Text("Recent Activity")
          .font(.system(size: 16, weight: .bold))
        Spacer()
      },
    ) {
      if recentActivity.isEmpty {
        activityEmptyState
      } else {
        VStack(spacing: 16) {
          ForEach(recentActivity) { item in
            MintyUI.ActivityRow(entry: item.entry, person: item.person)
          }
        }
        .padding(.top, 14)
      }
    }
  }

  private var activityEmptyState: some View {
    VStack(spacing: 6) {
      Image(systemName: "sparkles")
        .font(.system(size: 30))
        .foregroundStyle(Color("primary_green").opacity(0.5))
        .padding(.bottom, 2)
      Text("No activity yet")
        .font(.system(size: 15, weight: .semibold))
      Text("Tap a kid to record their first chore.")
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(Color("dark_grey").opacity(0.6))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 36)
  }

  private func people(role: Role) -> [Person] {
    (stateManager.family?.people ?? [])
      .filter { $0.role == role }
      .sorted { ($0.sortOrder, $0.name) < ($1.sortOrder, $1.name) }
  }
}

// MARK: - ActivityItem

/// Pairs a ledger entry with the person it belongs to, since an entry only
/// links back to its `Ledger`.
private struct ActivityItem: Identifiable {
  let person: Person
  let entry: LedgerEntry

  var id: PersistentIdentifier { entry.persistentModelID }
}

#Preview {
  let preview = Preview()

  NavigationStack {
    HomeView()
  }
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
