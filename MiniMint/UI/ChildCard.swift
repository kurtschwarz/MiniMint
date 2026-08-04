import SwiftUI

extension MintyUI {
  // MARK: - ChildCard

  /// A payment-card-styled tile for a single child: their signature avatar
  /// colour, emoji as the brand mark, and their balance as the amount. Sized to
  /// a standard card ratio so a row of them reads as a wallet.
  struct ChildCard: View {

    // MARK: Lifecycle

    init(person: Person, currencyName: String) {
      self.person = person
      self.currencyName = currencyName
    }

    // MARK: Internal

    var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: MintyUI.Radius.standard, style: .continuous)
          .fill(
            LinearGradient(
              colors: [baseColor, baseColor.adjust(saturation: 0.12, brightness: -0.18, opacity: 0)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing,
            ),
          )
          // A very subtle inner shadow: a faint light edge along the top and a
          // soft dark edge along the bottom so the card reads as slightly raised.
          .overlay {
            RoundedRectangle(cornerRadius: MintyUI.Radius.standard, style: .continuous)
              .stroke(
                LinearGradient(
                  colors: [Color.white.opacity(0.45), Color.black.opacity(0.16)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing,
                ),
                lineWidth: 1,
              )
              .blur(radius: 0.5)
          }

        VStack(alignment: .leading, spacing: 0) {
          HStack(alignment: .top) {
            Text(currencyName.uppercased())
              .font(.system(size: 12, weight: .semibold))
              .tracking(1)
              .foregroundStyle(ink.opacity(0.6))

            Spacer(minLength: 8)

            if let emoji = person.avatar?.emoji, let scalar = UnicodeScalar(emoji) {
              Text(String(scalar))
                .font(.system(size: 30))
            }
          }

          Spacer(minLength: 8)

          MintyUI.CurrencyAmount(person.balance, size: 30)
            .foregroundStyle(ink)

          Spacer(minLength: 10)

          Text(person.name)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(ink)
        }
        .padding(20)
      }
      .aspectRatio(1.586, contentMode: .fit)
      .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }

    // MARK: Private

    private let person: Person
    private let currencyName: String

    /// Ink that stays legible on the pastel avatar colours used for backgrounds.
    private var ink: Color { Color("dark_grey") }

    private var baseColor: Color {
      person.avatar?.background.map { Color(hex: $0) } ?? Color("light_gray")
    }
  }
}

#Preview {
  let preview = Preview()

  return MintyUI.ChildCard(
    person: preview.family.people.first { $0.role == .child }!,
    currencyName: preview.family.currency?.name ?? "Coins",
  )
  .padding()
}
