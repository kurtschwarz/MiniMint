import SwiftData
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

    // Newest first across the whole store. SwiftData predicates can't reliably
    // walk the entry -> ledger -> person chain, so scope to this person in
    // memory below; a family's entry count stays small.
    @Query(sort: \LedgerEntry.date, order: .reverse) var allEntries: [LedgerEntry]

    var personId: PersistentIdentifier?

    var body: some View {
      VStack(alignment: .leading, spacing: 16) {
        if entries.isEmpty {
          emptyState
        } else {
          ForEach(entries) { entry in
            if let person = entry.ledger?.person {
              MintyUI.ActivityRow(entry: entry, person: person)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 20)
      .padding(.horizontal, 20)
    }

    // MARK: Private

    /// This person's postings, newest first.
    private var entries: [LedgerEntry] {
      allEntries.filter { $0.ledger?.person?.persistentModelID == personId }
    }

    private var emptyState: some View {
      VStack(spacing: 6) {
        Image(systemName: "sparkles")
          .font(.system(size: 30))
          .foregroundStyle(Color("primary_green").opacity(0.5))
          .padding(.bottom, 2)
        Text("No activity yet")
          .font(.system(size: 15, weight: .semibold))
        Text("Record an action to start their history.")
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(Color("dark_grey").opacity(0.6))
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 36)
    }

  }

}
