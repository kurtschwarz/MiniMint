import Foundation
import SwiftData

// MARK: - ActionType

enum ActionType: Int, Codable, CaseIterable, Identifiable {
  case deposit
  case withdrawl

  // MARK: Internal

  var id: Self { self }
}

// MARK: - Action

@Model
final class Action {

  // MARK: Lifecycle

  init(name: String, type: ActionType = .deposit, amount: UInt64 = 0, family: Family? = nil, avatar: Avatar? = nil) {
    self.name = name
    self.type = type.rawValue
    self.amount = amount
    self.family = family
    self.avatar = avatar
  }

  // MARK: Public

  public var type: Int

  @Transient
  public var actionType: ActionType {
    ActionType(rawValue: type) ?? .deposit
  }

  // MARK: Internal

  var name: String
  var amount: UInt64 = 0
  @Relationship var avatar: Avatar?
  @Relationship(inverse: \Family.actions) var family: Family?
  @Relationship(inverse: \ActionGroup.actions) var group: ActionGroup?

}
