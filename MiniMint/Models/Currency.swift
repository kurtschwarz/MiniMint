import Foundation
import SwiftData
import SwiftUI

@Model
final class Currency {

  // MARK: Lifecycle

  init(
    name: String? = nil,
    avatar: Avatar? = nil,
  ) {
    self.name = name ?? Currency.generateName()
    self.avatar = avatar
  }

  // MARK: Internal

  static var generatedNamesCache: (options: [String], current: [String]) = {
    if let asset = NSDataAsset(name: "random_currency_names") {
      let options = (try! JSONSerialization.jsonObject(with: asset.data, options: []) as! [String]).shuffled()
      return (
        options: options,
        current: options.map { $0 },
      )
    }

    return (options: [], current: [])
  }()

  @Attribute(.unique) var name: String
  @Relationship(.unique, deleteRule: .cascade) var avatar: Avatar?

  static func generateName() -> String {
    if Currency.generatedNamesCache.current.isEmpty {
      Currency.generatedNamesCache.current = Currency.generatedNamesCache.options.map { $0 }
    }

    return Currency.generatedNamesCache.current.removeLast()
  }
}
