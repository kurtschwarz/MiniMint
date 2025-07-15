import SwiftUI

extension MintyUI {

  struct Tab<Content: View>: View {

    // MARK: Lifecycle

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
      self.title = title
      self.content = content
    }

    // MARK: Internal

    var title: String

    var content: () -> Content

    var body: some View {
      Text("Tab")
    }
  }

  struct TabView<Content: View>: View {

    // MARK: Lifecycle

    init(@ViewBuilder content: @escaping () -> Content) {
      self.content = content
    }

    // MARK: Internal

    var content: () -> Content

    var body: some View {
      content()
    }

  }

}
