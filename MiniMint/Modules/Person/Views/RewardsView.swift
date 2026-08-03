import SwiftUI

extension PersonView {

  struct RewardsView: View {

    // MARK: Public

    public func pageLabel() -> MintyUI.PageLabel {
      MintyUI.PageLabel(title: "Rewards")
    }

    @ViewBuilder public func stickyBottomView(
      navigate: NavigateAction,
    ) -> some View {
      Button(action: { navigate(.sheet(.createReward, .medium)) }) {
        Text("Create Reward")
      }
      .tint(.primaryGreen)
      .buttonStyle(.borderedProminent)
    }

    // MARK: Internal

    var body: some View {
      VStack(alignment: .leading) {
        Text("Rewards View")
      }
      .padding(.vertical, 20)
      .padding(.horizontal, 20)
    }
  }

}
