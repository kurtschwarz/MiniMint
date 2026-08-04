import Foundation
import SwiftData

// MARK: - LedgerEntryType

/// Whether a posting adds to or removes from a wallet's balance.
enum LedgerEntryType: Int, Codable, CaseIterable, Identifiable {
  case deposit
  case withdrawl

  // MARK: Internal

  var id: Self { self }
}

// MARK: - LedgerEntry

/// A single posting in a wallet — the atomic unit of a `Ledger`. It carries its
/// own `type` and `amount`, captured when recorded, so it stays an immutable
/// snapshot even if the source `Action` is later edited or deleted.
@Model
final class LedgerEntry {

  // MARK: Lifecycle

  init(
    ledger: Ledger? = nil,
    type: LedgerEntryType = .deposit,
    amount: UInt64 = 0,
    date: Date? = Date.now,
    action: Action? = nil,
    note: String? = nil,
  ) {
    self.ledger = ledger
    self.type = type.rawValue
    self.amount = amount
    self.date = date
    self.action = action
    self.note = note
  }

  // MARK: Public

  public var type: Int

  @Transient
  public var entryType: LedgerEntryType {
    LedgerEntryType(rawValue: type) ?? .deposit
  }

  /// Signed effect this posting has on the wallet balance.
  @Transient
  public var signedAmount: Int64 {
    switch entryType {
    case .deposit: Int64(amount)
    case .withdrawl: -Int64(amount)
    }
  }

  // MARK: Internal

  var amount: UInt64 = 0
  var date: Date?
  /// Optional comment the recording adult attaches to this entry.
  var note: String?

  @Relationship(inverse: \Ledger.entries) var ledger: Ledger?
  /// The action this posting records, if any.
  @Relationship var action: Action?

}
