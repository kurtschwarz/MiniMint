import SwiftUI

extension PersonView {

  struct ActivityView: View {

    // MARK: Public

    public func pageLabel() -> MintyUI.PageLabel {
      MintyUI.PageLabel(title: "Activity")
    }

    @ViewBuilder public func stickyBottomView(
      navigate _: NavigateAction,
    ) -> some View {
      EmptyView()
    }

    // MARK: Internal

    var body: some View {
      VStack(alignment: .leading) {
        Text("Activity View")
      }
      .padding(.vertical, 20)
      .padding(.horizontal, 20)
    }

  }

}
