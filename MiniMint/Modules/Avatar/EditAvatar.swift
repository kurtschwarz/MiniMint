import SwiftData
import SwiftUI

struct EditAvatarView: View {

  // MARK: Lifecycle

  init(id: PersistentIdentifier? = nil) {
    self.id = id
  }

  // MARK: Internal

  var id: PersistentIdentifier? = nil

  var body: some View {
    VStack {
      Text("Edit Avatar")
    }
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext
}

#Preview {
  let preview = Preview()

  NavigationStack {
    EditAvatarView()
  }
  .modelContainer(preview.modelContainer)
}
