import Foundation
import SwiftData

@Model
final class Avatar: Codable {

  // MARK: Lifecycle

  init(
    symbol: String? = nil,
    emoji: UInt32? = nil,
    background: UInt? = nil,
    image: Data? = nil,
  ) {
    self.symbol = symbol
    self.emoji = emoji
    self.background = background
    self.image = image
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if var emojiString = try container.decodeIfPresent(String.self, forKey: .emoji) {
      if emojiString.hasPrefix("0x") {
        emojiString.removeFirst(2)
      }

      emoji = UInt32(emojiString, radix: 16)
    }

    if var backgroundString = try container.decodeIfPresent(String.self, forKey: .background) {
      if backgroundString.hasPrefix("0x") {
        backgroundString.removeFirst(2)
      }

      background = UInt(backgroundString, radix: 16)
    }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case emoji
    case background
  }

  var symbol: String? = nil
  var emoji: UInt32? = nil
  var background: UInt? = nil
  @Attribute(.externalStorage) var image: Data? = nil

  static func generate() -> Avatar {
    return .init(emoji: 0x1F424, background: 0xFFE0E2)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(emoji, forKey: .emoji)
    try container.encode(background, forKey: .background)
  }

}
