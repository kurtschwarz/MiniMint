import SwiftUI

// MARK: - OffsetKey

struct OffsetKey: PreferenceKey {
  static var defaultValue = CGRect.zero

  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}

// MARK: - AccentColorAction

struct AccentColorAction {
  typealias Action = (Color) -> Void

  let action: Action

  func callAsFunction(_ color: Color) {
    action(color)
  }
}

extension View {

  func onNavigate(_ action: @escaping NavigateAction.Action) -> some View {
    environment(\.navigate, NavigateAction(action: action))
  }

  func onAccentColor(_ action: @escaping AccentColorAction.Action) -> some View {
    environment(\.accentColor, AccentColorAction(action: action))
  }

  @ViewBuilder
  func offsetX(completion: @escaping (CGRect) -> Void) -> some View {
    overlay {
      GeometryReader { proxy in
        let rect = proxy.frame(in: .global)

        Color.clear
          .preference(key: OffsetKey.self, value: rect)
          .onPreferenceChange(OffsetKey.self, perform: completion)
      }
    }
  }

}
