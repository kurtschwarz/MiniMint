import SwiftData
import SwiftUI

struct HomeView: View {

  // MARK: Internal

  var body: some View {
    VStack {
      Text("Home!")
      Text("\(String(describing: stateManager.family?.name ?? ""))")
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
    .navigationBarTitle("")
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
