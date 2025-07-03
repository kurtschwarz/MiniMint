import SwiftUI

struct PeopleList: View {

  // MARK: Lifecycle

  init(people: [Person] = [], showAddPersonButton: Bool = false) {
    self.people = people
    self.showAddPersonButton = showAddPersonButton
  }

  // MARK: Internal

  var body: some View {
    ScrollView(.horizontal) {
      LazyHStack(alignment: .top) {
        ForEach(people) { person in
          VStack(alignment: .center, spacing: 0) {
            if person.avatar != nil {
              CircleAvatar(avatar: person.avatar!)
            }

            Text(person.name)
              .font(.system(size: 16, weight: .bold))
              .padding(.top, 10)
              .padding(.bottom, 2)

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

  private var people: [Person] = []

  private var showAddPersonButton = false

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
