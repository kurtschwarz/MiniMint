import SwiftUI

struct DashboardView: View {
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
          action: {},
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
}

#Preview {
  NavigationStack {
    DashboardView()
  }
}
