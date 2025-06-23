import SwiftUI

struct DashboardView: View {
  // MARK: Internal

  var body: some View {
    VStack {
      Text("Dashboard!")
    }
    .toolbar(content: {
//      ToolbarItem(placement: .topBarTrailing) {
//        Button(
//          action: {},
//          label: {
//            Image(systemName: "bell.badge")
//              .foregroundStyle(.red, Color("primary_green"))
//          },
//        )
//      }

      ToolbarItem(placement: .topBarTrailing) {
        Button(
          action: { },
          label: {
            Image(systemName: "person")
              .foregroundStyle(Color("primary_green"))
          },
        )
      }
    })
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
    .navigationBarTitle("")
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @EnvironmentObject private var appState: AppState
}

#Preview {
  NavigationStack {
    DashboardView()
      .environmentObject(AppState())
  }
}
