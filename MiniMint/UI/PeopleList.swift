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
          VStack {
            if person.avatar != nil {
              CircleAvatar(avatar: person.avatar!)
            }

            Text(person.name)
              .font(.system(size: 14, weight: .medium))
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
