import Foundation
import SwiftData

// MARK: - TransactionError

/// Why a transaction was refused. Surfaced to the UI so the adult sees why a
/// recording did not go through.
enum TransactionError: LocalizedError, Equatable {

  /// A withdrawal larger than what the wallet holds. Carries the wallet's
  /// current balance and the amount that was requested.
  case insufficientFunds(available: Int64, requested: UInt64)

  // MARK: Internal

  var errorDescription: String? {
    switch self {
    case .insufficientFunds(let available, let requested):
      "This would spend \(requested) but the balance is only \(available)."
    }
  }
}

// MARK: - LedgerManager

/// The single place ledger postings are written. Every deposit and withdrawal
/// goes through here so validation (e.g. a withdrawal cannot overdraw the
/// wallet) and the balance bookkeeping live in one spot instead of being
/// re-implemented at each call site.
struct LedgerManager {

  // MARK: Lifecycle

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  // MARK: Internal

  /// Whether `person` currently holds enough to cover a withdrawal of `amount`.
  /// Deposits are always allowed, so this only ever constrains withdrawals.
  func canWithdraw(_ amount: UInt64, from person: Person) -> Bool {
    (person.ledger?.balance ?? 0) >= Int64(amount)
  }

  /// Record `action` against `person`, posting a `LedgerEntry` and moving the
  /// wallet balance by its signed amount. Withdrawals are rejected when the
  /// wallet cannot cover them. On success the new entry is returned; the caller
  /// is responsible for any UI reaction.
  @discardableResult
  func record(
    action: Action,
    for person: Person,
    on date: Date? = .now,
    note: String? = nil,
  ) throws -> LedgerEntry {
    // Snapshot the type and amount now so the entry keeps its value even if the
    // source action is later edited or deleted.
    let entryType: LedgerEntryType = action.actionType.isDeposit ? .deposit : .withdrawl

    return try post(
      type: entryType,
      amount: action.amount,
      for: person,
      on: date,
      action: action,
      note: note,
    )
  }

  /// Post a raw entry into `person`'s wallet. This is the primitive `record`
  /// builds on; use it directly when there is no source `Action` (e.g. a manual
  /// adjustment). Validates withdrawals, writes the entry, moves the cached
  /// balance, and saves — all in one transaction so the entry and the balance
  /// can never drift apart on a partial failure.
  @discardableResult
  func post(
    type: LedgerEntryType,
    amount: UInt64,
    for person: Person,
    on date: Date? = .now,
    action: Action? = nil,
    note: String? = nil,
  ) throws -> LedgerEntry {
    // Every person gets a wallet at creation, but guard so a legacy person
    // without one still records cleanly.
    let ledger = ledger(for: person)

    if type == .withdrawl, ledger.balance < Int64(amount) {
      throw TransactionError.insufficientFunds(available: ledger.balance, requested: amount)
    }

    let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)

    let entry = LedgerEntry(
      ledger: ledger,
      type: type,
      amount: amount,
      date: date,
      action: action,
      note: (trimmedNote?.isEmpty ?? true) ? nil : trimmedNote,
    )

    try modelContext.transaction {
      modelContext.insert(entry)
      ledger.balance += entry.signedAmount
    }

    return entry
  }

  // MARK: Private

  private let modelContext: ModelContext

  /// The person's wallet, creating and attaching one if a legacy person is
  /// missing it.
  private func ledger(for person: Person) -> Ledger {
    if let existing = person.ledger {
      return existing
    }

    let ledger = Ledger(person: person)
    person.ledger = ledger
    return ledger
  }

}
