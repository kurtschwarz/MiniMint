
import SwiftData

// MARK: - ActionType

enum ActionType: Codable {
  case deposit
  case withdrawl
}

// MARK: - Action

@Model
final class Action {

  // MARK: Lifecycle

  init(name: String, type: ActionType = .deposit, amount: UInt64 = 0, family: Family? = nil, avatar: Avatar? = nil) {
    self.name = name
    self.type = type
    self.amount = amount
    self.family = family
    self.avatar = avatar
  }

  // MARK: Internal

  var name: String
  var type = ActionType.deposit
  var amount: UInt64 = 0
  @Relationship var avatar: Avatar?
  @Relationship(inverse: \Family.actions) var family: Family?
}
