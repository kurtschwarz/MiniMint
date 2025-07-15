import Foundation
import SwiftData

@Model
final class LedgerEntry {

  // MARK: Lifecycle

  init(ledger: Ledger? = nil, date: Date? = Date.now, action: Action? = nil) {
    self.ledger = ledger
    self.date = date
    self.action = action
  }

  // MARK: Internal

  var date: Date?
  @Relationship() var action: Action?
  @Relationship(inverse: \Ledger.entries) var ledger: Ledger?

}
