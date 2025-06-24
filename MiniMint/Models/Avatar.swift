import Foundation
import SwiftData

@Model
final class Avatar {

  // MARK: Lifecycle

  init(
    symbol: String? = nil,
    emoji: UInt32? = nil,
    background: String? = nil,
    image: Data? = nil,
  ) {
    self.symbol = symbol
    self.emoji = emoji
    self.background = background
    self.image = image
  }

  // MARK: Internal

  var symbol: String? = nil
  var emoji: UInt32? = nil
  var background: String? = nil
  @Attribute(.externalStorage) var image: Data? = nil
}
