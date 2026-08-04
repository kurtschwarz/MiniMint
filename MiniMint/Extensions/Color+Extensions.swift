import SwiftUI

extension Color {

  // MARK: Lifecycle

  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha,
    )
  }

  // MARK: Internal

  /// A soft, near-white background wash whose hue is blended from a group of
  /// avatars' background colours. Cohesive with the avatars without ever reading
  /// as a bold block of colour — saturation and brightness are pinned into a
  /// tint band so white content still sits cleanly on top. Falls back to the
  /// app's neutral grey when the group has no usable colour (empty, or every
  /// avatar effectively neutral).
  static func groupWash(
    for avatars: [Avatar],
    saturation: CGFloat = 0.114,
    brightness: CGFloat = 0.99,
  ) -> Color {
    let neutral = Color("light_gray")

    // Pull HSB for each avatar background that has one.
    let components: [(hue: CGFloat, saturation: CGFloat)] = avatars.compactMap { avatar in
      guard let hex = avatar.background else { return nil }
      var hue: CGFloat = 0
      var sat: CGFloat = 0
      var brightness: CGFloat = 0
      var alpha: CGFloat = 0
      guard UIColor(Color(hex: hex)).getHue(&hue, saturation: &sat, brightness: &brightness, alpha: &alpha) else {
        return nil
      }
      return (hue, sat)
    }

    guard !components.isEmpty else { return neutral }

    // Circular mean of hue, weighted by each avatar's saturation so near-grey
    // avatars — whose hue carries no real meaning — don't drag the blend toward
    // red. Averaging on the wheel keeps e.g. red + magenta from cancelling to green.
    var x: CGFloat = 0
    var y: CGFloat = 0
    for component in components {
      let angle = component.hue * 2 * .pi
      x += cos(angle) * component.saturation
      y += sin(angle) * component.saturation
    }

    // Every avatar was effectively neutral — no hue to tint toward.
    guard x != 0 || y != 0 else { return neutral }

    var hue = atan2(y, x) / (2 * .pi)
    if hue < 0 { hue += 1 }

    return Color(hue: hue, saturation: saturation, brightness: brightness)
  }

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
