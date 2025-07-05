import SwiftUI

// MARK: - AvatarSize

enum AvatarSize: Int, CaseIterable {
  case small
  case medium
  case large

  // MARK: Internal

  var fontSize: CGFloat {
    switch self {
    case .small: return 14
    case .medium: return 28
    case .large: return 56
    }
  }

  var frameSize: CGFloat {
    switch self {
    case .small: return 32
    case .medium: return 64
    case .large: return 128
    }
  }
}

// MARK: - CircleAvatar

struct CircleAvatar: View {
  var avatar: Avatar
  var size = AvatarSize.small

  var body: some View {
    VStack {
      if avatar.emoji != nil {
        Text(String(UnicodeScalar(avatar.emoji!)!))
          .font(.system(size: size.fontSize))
      }
    }
    .frame(width: size.frameSize, height: size.frameSize)
    .background(
      avatar.background != nil
        ? Color(hex: avatar.background!)
        : Color.gray
    )
    .cornerRadius(size.frameSize / 2)
  }
}

#Preview {
  CircleAvatar(
    avatar: .init(),
    size: .medium,
  )
}
