import SwiftUI

extension MintyUI {
  // MARK: - CurrencyAmount

  /// Renders a currency value (a balance or an action's amount) as the number
  /// trailed by the coin icon.
  struct CurrencyAmount: View {

    // MARK: Lifecycle

    init(_ amount: some BinaryInteger, size: CGFloat = 14) {
      self.amount = Int64(amount)
      self.size = size
    }

    // MARK: Internal

    var body: some View {
      HStack {
        Text(String(amount))
          .font(.system(size: size, weight: .medium))
      }
      .padding(.trailing, iconSize - 5)
      .background(
        alignment: .trailing,
        content: {
          Image("coin_icon")
            .resizable()
            .frame(width: iconSize, height: iconSize)
        },
      )
    }

    // MARK: Private

    private let amount: Int64
    private let size: CGFloat

    private var iconSize: CGFloat {
      size + 2
    }
  }
}

#Preview {
  MintyUI.CurrencyAmount(120)
}
