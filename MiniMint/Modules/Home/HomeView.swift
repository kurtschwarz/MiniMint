import SwiftData
import SwiftUI

struct HomeView: View {

  // MARK: Internal

  var body: some View {
    VStack {
      Section(
        header: HStack {
          Text("Your Crew")
            .font(.system(size: 16, weight: .bold))
          Spacer()
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
            people: (stateManager.family?.people ?? []).filter { person in person.role == .child },
            showAddPersonButton: true,
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
            people: (stateManager.family?.people ?? []).filter { person in person.role == .parent },
            showAddPersonButton: true,
            showBalance: false,
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

      ToolbarItem(placement: .topBarTrailing) {
        Button(
          action: {
            stateManager.reset()
          },
          label: {
            Image(systemName: "trash.fill").foregroundStyle(Color.white)
            Text("Reset").foregroundStyle(Color.white)
          },
        )
        .buttonStyle(.borderedProminent)
        .accentColor(Color.red)
      }
    })
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
    .background(Color.white, ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext
  @Environment(StateManager.self) private var stateManager: StateManager
}

#Preview {
  let preview = Preview()

  NavigationStack {
    HomeView()
  }
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
