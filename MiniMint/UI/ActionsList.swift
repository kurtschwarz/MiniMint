import SwiftData
import SwiftUI

extension MintyUI {
  struct ActionsList: View {
    var actions: [Action] = []

    var body: some View {
      ScrollView(.vertical) {
        LazyVStack(spacing: 14) {
          ForEach(actions) { action in
            HStack {
              MintyUI.CircleAvatar(
                avatar: action.avatar,
                size: .small,
              )

              Text(action.name)
              Spacer()
              HStack {
                Text(String(action.amount))
                  .font(.system(size: 14, weight: .medium))
              }
              .padding(.trailing, 11)
              .background(
                alignment: .trailing,
                content: {
                  Image("coin_icon")
                    .resizable()
                    .frame(width: 16, height: 16)
                },
              )
            }
          }
        }
      }
    }
  }
}

#Preview {
  let preview = Preview()

  MintyUI.ActionsList(
    actions: [
      .init(name: "Help someone carry groceries or open doors", type: .deposit, amount: 30, avatar: .generate()),
      .init(name: "Give three genuine compliments to others", type: .deposit, amount: 30, avatar: .generate()),
      .init(name: "Resolve a conflict peacefully with siblings/friends", type: .deposit, amount: 30, avatar: .generate()),
      .init(name: "Draw, paint, or create an art project", type: .deposit, amount: 30, avatar: .generate()),
      .init(name: "Build something with LEGOs or other construction toys", type: .deposit, amount: 30, avatar: .generate()),
    ],
  )
  .modelContainer(preview.modelContainer)
}
