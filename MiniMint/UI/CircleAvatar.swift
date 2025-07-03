import SwiftUI

struct CircleAvatar: View {
  var avatar: Avatar

  var body: some View {
    VStack {
      if avatar.emoji != nil {
        Text(String(UnicodeScalar(avatar.emoji!)!))
          .font(.system(size: 28))
      }
    }
    .frame(width: 64, height: 64)
    .background(
      avatar.background != nil
        ? Color(hex: avatar.background!)
        : Color.gray
    )
    .cornerRadius(32)
  }
}

#Preview {
  CircleAvatar(
    avatar: .init(),
  )
}
