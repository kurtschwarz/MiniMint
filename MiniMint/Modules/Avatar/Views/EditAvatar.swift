import SwiftUI

struct EditAvatarView: View {

  // MARK: Internal

  @FocusState var focused: Bool?

  var body: some View {
    NavigationView {
      VStack {
        VStack {
          TextField("", text: $emoji)
            .keyboardType(.emoji!)
            .focused($focused, equals: true)
            .disabled(selection != 0)
            .autocorrectionDisabled()
            .font(.system(size: 54))
            .tint(.clear)
            .multilineTextAlignment(.center)
            .onChange(of: emoji, initial: false) { _, newValue in
              emoji = String(newValue.suffix(1))
              avatar.emoji = emoji.unicodeScalars.first?.value
            }
        }
        .frame(width: 128, height: 128)
        .background(avatar.background != nil ? Color(hex: avatar.background!) : Color.gray)
        .cornerRadius(64)
        .padding(.top, 40)
        .padding(.bottom, 60)

        Picker("", selection: $selection) {
          Text("Emoji").tag(0)
          Text("Style").tag(1)
        }
        .padding(.bottom, 40)
        .pickerStyle(.segmented)
        .onChange(of: selection, initial: false) { oldSelection, newSelection in
          if oldSelection != newSelection {
            focused = newSelection == 0
          }
        }

        if selection == 1 {
          LazyVGrid(
            columns: [
              GridItem(.flexible(minimum: 32, maximum: 64)),
              GridItem(.flexible(minimum: 32, maximum: 64)),
              GridItem(.flexible(minimum: 32, maximum: 64)),
              GridItem(.flexible(minimum: 32, maximum: 64)),
              GridItem(.flexible(minimum: 32, maximum: 64)),
            ],
          ) {
            ForEach(Avatar.backgroundOptions, id: \.self, content: { background in
              CircleAvatar(
                avatar: .init(
                  emoji: avatar.emoji,
                  background: background,
                ),
                size: .medium,
              )
              .onTapGesture {
                avatar.background = background
              }
            })
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
              modelContext.insert(avatar)
              try? modelContext.save()

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
    }
    .onAppear {
      focused = true
    }
  }

  // MARK: Private

  @State var avatar = Avatar()

  @State private var emoji = ""
  @State private var selection = 0

  @FocusState private var emojiFieldFocused: Bool

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

}

#Preview {
  let preview = Preview()

  NavigationStack { }
    .sheet(isPresented: .constant(true)) {
      EditAvatarView()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    .modelContainer(preview.modelContainer)
}
