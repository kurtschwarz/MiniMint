import SwiftUI

extension Color {

  // MARK: Lifecycle

  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }

  // MARK: Internal

  func adjust(hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, opacity: CGFloat = 1) -> Color {
    let color = UIColor(self)
    var currentHue: CGFloat = 0
    var currentSaturation: CGFloat = 0
    var currentBrigthness: CGFloat = 0
    var currentOpacity: CGFloat = 0

    if color.getHue(&currentHue, saturation: &currentSaturation, brightness: &currentBrigthness, alpha: &currentOpacity) {
      return Color(
        hue: currentHue + hue,
        saturation: currentSaturation + saturation,
        brightness: currentBrigthness + brightness,
        opacity: currentOpacity + opacity,
      )
    }

    return self
  }

}
