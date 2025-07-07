import Foundation
import SwiftData
import SwiftUI

// MARK: - EditAvatarView

struct SelectAvatarView: View {

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
  @State var showEditorView = false

  var avatarId: PersistentIdentifier? = nil

  var body: some View {
    NavigationView {
      VStack {
        VStack {
          CircleAvatar(
            avatar: avatar,
            size: .large,
          )
          .onTapGesture {
            showEditorView = true
          }
        }
        .padding(.top, 40)
        .padding(.bottom, 60)

        LazyVGrid(
          columns: [
            GridItem(.flexible(minimum: 32, maximum: 64)),
            GridItem(.flexible(minimum: 32, maximum: 64)),
            GridItem(.flexible(minimum: 32, maximum: 64)),
            GridItem(.flexible(minimum: 32, maximum: 64)),
            GridItem(.flexible(minimum: 32, maximum: 64)),
          ],
        ) {
          Button(
            action: {
              showEditorView = true
            },
          ) {
            Image(systemName: "plus")
              .font(.system(size: 24, weight: .regular))
              .foregroundStyle(Color("dark_grey"))
          }
          .buttonStyle(PlainButtonStyle())
          .frame(width: 64, height: 64)
          .background(Color("light_gray"))
          .cornerRadius(32)

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

        Spacer()
      }
      .padding(.vertical, 40)
      .padding(.horizontal, 20)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(
            action: {
              dismiss()
            },
            label: {
              Text("Cancel")
            }
          )
          .buttonStyle(.plain)
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button(
            action: {
              dismiss()
            },
            label: {
              Text("Done")
            }
          )
          .buttonStyle(.plain)
        }
      }
      .sheet(isPresented: $showEditorView) {
        EditAvatarView(
          avatar: avatar!,
        )
      }
      .onAppear(perform: loadAvatar)
      .onAppear(perform: loadEmojiAvatars)
    }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss

  @Environment(\.modelContext) private var modelContext
  @Environment(\.navigate) private var navigate

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

  NavigationStack { }
    .sheet(isPresented: .constant(true)) {
      SelectAvatarView()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    .modelContainer(preview.modelContainer)
}
