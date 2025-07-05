import SwiftUI

struct PeopleList: View {

  // MARK: Lifecycle

  init(people: [Person] = [], showAddPersonButton: Bool = false, showBalance: Bool = true) {
    self.people = people
    self.showAddPersonButton = showAddPersonButton
    self.showBalance = showBalance
  }

  // MARK: Internal

  var body: some View {
    ScrollView(.horizontal) {
      LazyHStack(alignment: .top) {
        ForEach(people) { person in
          VStack(alignment: .center, spacing: 0) {
            if person.avatar != nil {
              CircleAvatar(
                avatar: person.avatar!,
                size: .medium,
              )
            }

            Text(person.name)
              .font(.system(size: 14, weight: .bold))
              .padding(.top, 10)
              .padding(.bottom, 2)

            if self.showBalance {
              HStack {
                Text(String(person.balance))
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
          .onTapGesture {
            navigate(.push(.person(person.persistentModelID)))
          }
        }

        if self.showAddPersonButton {
          Button(action: { }) {
            Image(systemName: "plus")
              .font(.system(size: 24, weight: .regular))
              .foregroundStyle(Color("dark_grey"))
          }
          .buttonStyle(PlainButtonStyle())
          .frame(width: 64, height: 64)
          .background(Color("light_gray"))
          .cornerRadius(32)
        }
      }
      .fixedSize(horizontal: false, vertical: true)
    }
  }

  // MARK: Private

  @Environment(\.navigate) private var navigate

  private var people: [Person] = []
  private var showAddPersonButton = false
  private var showBalance = true

}

#Preview {
  let preview = Preview()

  PeopleList(
    people: preview.family.people.filter { person in
      person.role == .child
    },
    showAddPersonButton: true,
  )
}
