import SwiftUI

extension MiniMintUI {

  struct Tab {
    var label: String
    var view: AnyView
  }

  struct TabView: View {

    var tabs: [Tab] = []

    var body: some View {
      HStack(spacing: 2) {
        ForEach(tabs, id: \.self.label) { tab in
          let selected = selectedTab == tab.label

          Button(action: {
            selectedTab = tab.label
          }) {
            Text(tab.label)
              .foregroundStyle(selected ? .white : .primaryGreen)
          }
          .buttonStyle(.plain)
          .padding(.vertical, 10)
          .padding(.horizontal, 20)
          .background(selected ? .primaryGreen : .clear)
          .cornerRadius(32)
        }
      }
      .padding(.vertical, 10)
      .padding(.horizontal, 20)
      .background(.backgroundPrimary)
      .cornerRadius(32)

      SwiftUI.TabView(selection: $selectedTab) {
        ForEach(tabs, id: \.self.label) { tab in
          tab.view
            .tag(tab.label)
        }
      }
      .tabViewStyle(.page)
    }

    @State var selectedTab: String? = nil

  }

}

#Preview {
  MiniMintUI.TabView(
    tabs: [
      .init(label: "Tab 1", view: AnyView(Text("Tab 1 Content"))),
      .init(label: "Tab 2", view: AnyView(Text("Tab 2 Content"))),
      .init(label: "Tab 3", view: AnyView(Text("Tab 3 Content"))),
    ],
    selectedTab: "Tab 1",
  )
}
