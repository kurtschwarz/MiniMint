import SwiftData
import SwiftUI

struct HomeView: View {

  // MARK: Internal

  var body: some View {
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

      Spacer()
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
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
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

  private func people(role: Role) -> [Person] {
    (stateManager.family?.people ?? [])
      .filter { $0.role == role }
      .sorted { ($0.sortOrder, $0.name) < ($1.sortOrder, $1.name) }
  }
}

#Preview {
  let preview = Preview()

  NavigationStack {
    HomeView()
  }
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
