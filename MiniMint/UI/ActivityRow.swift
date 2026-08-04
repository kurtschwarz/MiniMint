import SwiftData
import SwiftUI

extension MintyUI {
  // MARK: - ActivityRow

  /// A single line in a recent-activity feed: who did what, how much it moved
  /// the balance, and how long ago. Reused by the family dashboard and a
  /// person's own activity history.
  struct ActivityRow: View {

    // MARK: Lifecycle

    init(entry: LedgerEntry, person: Person) {
      self.entry = entry
      self.person = person
    }

    // MARK: Internal

    var body: some View {
      HStack(spacing: 12) {
        if let avatar = person.avatar {
          MintyUI.CircleAvatar(avatar: avatar, size: .small)
        }

        VStack(alignment: .leading, spacing: 2) {
          HStack(spacing: 4) {
            Text(person.name)
              .font(.system(size: 14, weight: .bold))
            Text(isCredit ? "earned" : "spent")
              .font(.system(size: 14, weight: .regular))
              .foregroundStyle(Color("dark_grey"))
          }

          if let name = entry.action?.name {
            Text(name)
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(Color("dark_grey").opacity(0.55))
          }
        }

        Spacer(minLength: 8)

        VStack(alignment: .trailing, spacing: 2) {
          amount

          if let date = entry.date {
            Text(date, format: .relative(presentation: .named))
              .font(.system(size: 11, weight: .medium))
              .foregroundStyle(Color("dark_grey").opacity(0.5))
          }
        }
      }
    }

    // MARK: Private

    private let entry: LedgerEntry
    private let person: Person

    /// Whether this posting added to the balance; drives the wording, sign and
    /// colour. Reads the entry's own type, not the source action.
    private var isCredit: Bool {
      entry.entryType == .deposit
    }

    private var amount: some View {
      HStack(spacing: 1) {
        Text(isCredit ? "+" : "−")
          .font(.system(size: 14, weight: .semibold))
        MintyUI.CurrencyAmount(entry.amount, size: 14)
      }
      .foregroundStyle(isCredit ? Color("primary_green") : Color(hex: 0xD9544D))
    }
  }
}
