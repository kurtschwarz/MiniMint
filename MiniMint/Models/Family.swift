import Foundation
import SwiftData
import SwiftUI

@Model
final class Family {

  // MARK: Lifecycle

  init(
    name: String? = nil,
    avatar: Avatar? = nil,
    currency: Currency? = nil,
    people: [Person]? = nil,
  ) {
    self.name = name ?? Family.generateName()
    self.avatar = avatar
    self.currency = currency
    self.people = people
  }

  // MARK: Internal

  static var generatedNamesCache: (options: [String], current: [String]) = {
    if let asset = NSDataAsset(name: "random_family_names") {
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
  @Relationship(.unique, deleteRule: .cascade) var currency: Currency?
  @Relationship(deleteRule: .cascade) var people: [Person]?

  static func generateName() -> String {
    if Family.generatedNamesCache.current.isEmpty {
      Family.generatedNamesCache.current = Family.generatedNamesCache.options.map { $0 }
    }

    return Family.generatedNamesCache.current.removeLast()
  }
}
