import Foundation
import SwiftData
import SwiftUI

struct EditAvatarView: View {

  // MARK: Lifecycle

  init(
    avatarId: PersistentIdentifier? = nil,
    avatar: Avatar? = nil,
  ) {
    self.avatarId = avatarId
    self.avatar = avatar
  }

  // MARK: Internal

  enum AvatarType: String, CaseIterable, Identifiable {
    case emoji
    case image

    // MARK: Internal

    var id: Self { self }
  }

  @State var avatar: Avatar? = nil
  @State var emojiAvatars: [Avatar] = []

  var avatarId: PersistentIdentifier? = nil

  var body: some View {
    VStack {
      LazyVGrid(
        columns: [
          GridItem(.fixed(64)),
          GridItem(.fixed(64)),
          GridItem(.fixed(64)),
          GridItem(.fixed(64)),
          GridItem(.fixed(64)),
        ],
      ) {
        ForEach(emojiAvatars) { emojiAvatar in
          CircleAvatar(
            avatar: emojiAvatar,
            size: .medium,
          )
          .onTapGesture {
            avatar?.emoji = emojiAvatar.emoji
            avatar?.background = emojiAvatar.background

            try? modelContext.save()
          }
        }
      }
      .padding(20)
    }
    .onAppear(perform: loadAvatar)
    .onAppear(perform: loadEmojiAvatars)
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext

  private func loadAvatar() {
    if avatarId != nil && avatar == nil {
      avatar = modelContext.model(for: avatarId!) as? Avatar
    }
  }

  private func loadEmojiAvatars() {
    if let asset = NSDataAsset(name: "emoji_avatars") {
      let decoder = JSONDecoder()

      emojiAvatars = try! decoder.decode(
        [Avatar].self,
        from: asset.data,
      )
    }
  }

}

#Preview {
  let preview = Preview()

  NavigationStack {
    EditAvatarView()
  }
  .modelContainer(preview.modelContainer)
}
