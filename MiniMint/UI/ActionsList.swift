import SwiftData
import SwiftUI

extension MintyUI {
  struct ActionsSection: View {

    // MARK: Lifecycle

    init(group: ActionGroup, type: ActionType) {
      self.group = group
      self.type = type

      let groupID = group.persistentModelID
      let typeValue = type.rawValue

      _actions = Query(
        filter: #Predicate<Action> { action in
          if let actionGroup = action.group {
            return actionGroup.persistentModelID == groupID && action.type == typeValue
          } else {
            return false
          }
        },
        sort: \.name,
      )
    }

    // MARK: Internal

    @Query var actions: [Action]

    var type: ActionType
    var group: ActionGroup

    var body: some View {
      Section(
        header: VStack(alignment: .leading) {
          Text(group.name)
            .fontWeight(.medium)
        }
      ) {
        if actions.isEmpty == false {
          ForEach(actions) { action in
            HStack {
              Text(action.name)

              Spacer()

              MintyUI.CurrencyAmount(action.amount)
            }
          }
        } else {
          Text("No actions found")
        }
      }
    }

    // MARK: Private

    @Environment(\.modelContext) private var modelContext
  }

  struct ActionsList: View {

    // MARK: Lifecycle

    init(familyId: PersistentIdentifier?, type: ActionType) {
      self.type = type

      if let familyId {
        _groups = Query(
          filter: #Predicate<ActionGroup> { group in
            if let family = group.family {
              return family.persistentModelID == familyId
            } else {
              return false
            }
          },
          sort: \.name,
        )
      } else {
        _groups = Query(
          filter: #Predicate<ActionGroup> { _ in false },
          sort: \.name,
        )
      }
    }

    // MARK: Internal

    @Query var groups: [ActionGroup]

    var type: ActionType

    var body: some View {
      LazyVStack(alignment: .leading, spacing: 28) {
        ForEach(groups) { group in
          ActionsSection(group: group, type: type)
        }
      }
    }
  }
}

#Preview {
  let preview = Preview()

  MintyUI.ActionsList(
    familyId: preview.family.persistentModelID,
    type: .deposit,
  )
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
