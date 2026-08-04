import SwiftData

/// A person's wallet: the running `balance` and the postings that got it there.
/// Owned by a single `Person` and cascade-deleted along with them.
@Model
final class Ledger {

  // MARK: Lifecycle

  init(person: Person? = nil, balance: Int64 = 0, entries: [LedgerEntry] = []) {
    self.person = person
    self.balance = balance
    self.entries = entries
  }

  // MARK: Internal

  /// Cached running total, moved by each posting so the balance can be read
  /// without summing the whole history. Reconcile from `entries` if it drifts.
  var balance: Int64 = 0

  @Relationship(inverse: \Person.ledger) var person: Person?
  @Relationship(deleteRule: .cascade) var entries: [LedgerEntry] = []

}
