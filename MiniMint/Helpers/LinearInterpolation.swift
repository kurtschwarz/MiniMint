import SwiftUI

class LinearInterpolation {

  // MARK: Lifecycle

  init(inputRange: [CGFloat], outputRange: [CGFloat]) {
    assert(inputRange.count == outputRange.count)
    length = inputRange.count - 1

    self.inputRange = inputRange
    self.outputRange = outputRange
  }

  // MARK: Internal

  func calculate(for x: CGFloat) -> CGFloat {
    if x <= inputRange[0] { return outputRange[0] }

    for index in 1...length {
      let x1 = inputRange[index - 1]
      let x2 = inputRange[index]

      let y1 = outputRange[index - 1]
      let y2 = outputRange[index]

      if x <= inputRange[index] {
        return y1 + ((y2 - y1) / (x2 - x1)) * (x - x1)
      }
    }

    return outputRange[length]
  }

  // MARK: Private

  private var length: Int
  private var inputRange: [CGFloat]
  private var outputRange: [CGFloat]

}
