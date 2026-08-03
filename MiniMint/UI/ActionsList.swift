import SwiftData
import SwiftUI

extension MintyUI {
  struct ActionsSection: View {

    // MARK: Lifecycle

    init(group: ActionGroup, type: ActionType) {
      self.group = group
      self.type = type

      _actions = Query(
        filter: #Predicate {
          return $0.group != nil
        },
      )
    }

    // MARK: Internal

    @Query() var actions: [Action] = []

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
            Text(action.name)
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

    init(type: ActionType) {
      self.type = type

//      _groups = Query(
//        filter: #Predicate {
//          guard let familyId = stateManager.familyId else {
//            return false
//          }
//
//          return $0.family?.persistentModelID == familyId
//        },
//      )
    }

    // MARK: Internal

    @Query() var groups: [ActionGroup]

    var type: ActionType

    var body: some View {
      LazyVStack(alignment: .leading, spacing: 14) {
        ForEach(groups) { group in
          ActionsSection(group: group, type: type)
        }
      }
//      .onAppear {
//        getActionGroups()
//      }
    }

    // MARK: Private

    @Environment(\.modelContext) private var modelContext
    @Environment(StateManager.self) private var stateManager: StateManager

    private func getActionGroups() {
//      guard let familyId = stateManager.familyId else {
//        return
//      }
//
//      if groups.count == 0 {
//        let filterByFamily = #Predicate<ActionGroup> {
//          if let family = $0.family {
//            return family.persistentModelID == familyId
//          } else {
//            return false
//          }
//        }
//
//        let filterByActionType = #Predicate<ActionGroup> {
//          $0.actions.contains {
//            $0.type == 1
//          }
//        }

//        var descriptor = FetchDescriptor<ActionGroup>(
//          predicate: #Predicate<ActionGroup> { group in
//            (group.family?.persistentModelID == stateManager.familyId) || false
      ////            groups.actions.contains { action in
      ////              action.name == "Withdrawl"
      ////            }
//          })

//        descriptor.relationshipKeyPathsForPrefetching = [
//          \.family,
//        ]

//        groups = try! modelContext
//          .fetch(descriptor)
//      }
    }
  }
}

#Preview {
  let preview = Preview()

  MintyUI.ActionsList(
    type: .deposit,
  )
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
