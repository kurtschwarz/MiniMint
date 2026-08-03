import SwiftData
import SwiftUI

extension PersonView {

  struct ActionsView: View {

    // MARK: Public

    public func pageLabel() -> MintyUI.PageLabel {
      MintyUI.PageLabel(title: "Actions")
    }

    @ViewBuilder public func stickyBottomView(
      personId: PersistentIdentifier,
      navigate: NavigateAction,
    ) -> some View {
      Button(action: { navigate(.sheet(.createAction(personId), .large)) }) {
        Text("Create Action")
      }
      .tint(.primaryGreen)
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
    }

    // MARK: Internal

    var body: some View {
      VStack(alignment: .leading) {
        MintyUI.ActionsList(type: .deposit)
      }
      .padding(.vertical, 20)
      .padding(.horizontal, 20)
    }
  }

}

#Preview {
  let preview = Preview()

  PersonView.ActionsView()
    .environment(preview.stateManager)
    .modelContainer(preview.modelContainer)
}
