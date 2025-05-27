import SwiftUI

struct DashboardView: View {
  var body: some View {
    VStack {
      Text("Dashboard")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 20)
    .navigationBarTitle("")
    .navigationBarBackButtonHidden(true)
    .navigationBarHidden(true)
  }
}

#Preview {
  DashboardView()
}
