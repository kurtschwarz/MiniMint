import Foundation
import SwiftData
import SwiftUI

@Model
final class Avatar: Codable {

  // MARK: Lifecycle

  // #Unique<Avatar>([\.symbol, \.background], [\.emoji, \.background])

  init(
    symbol: String? = nil,
    emoji: UInt32? = nil,
    background: UInt? = nil,
    image: Data? = nil,
  ) {
    self.symbol = symbol
    self.emoji = emoji
    self.background = background ?? Avatar.backgroundOptions.first
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

  static var backgroundOptions: [UInt] = {
    if let asset = NSDataAsset(name: "avatar_backgrounds") {
      let colors = (try! JSONSerialization.jsonObject(with: asset.data, options: []) as! [String])
      return colors.map {
        var colorString = String($0)

        if colorString.hasPrefix("0x") {
          colorString.removeFirst(2)
        }

        return UInt(colorString, radix: 16)!
      }
    }

    return []
  }()

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
