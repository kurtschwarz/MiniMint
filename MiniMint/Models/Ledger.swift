import SwiftData

@Model
final class Ledger {

  // MARK: Lifecycle

  init(person: Person? = nil, entries: [LedgerEntry]? = []) {
    self.person = person
    self.entries = entries
  }

  // MARK: Internal

  @Relationship(inverse: \Person.ledger) var person: Person?
  @Relationship(deleteRule: .cascade) var entries: [LedgerEntry]?

}
