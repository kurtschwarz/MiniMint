import SwiftUI

extension View {
  func onNavigate(_ action: @escaping NavigateAction.Action) -> some View {
    environment(\.navigate, NavigateAction(action: action))
  }
}
