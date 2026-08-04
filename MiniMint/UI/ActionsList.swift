import SwiftData
import SwiftUI

extension MintyUI {
  struct ActionsSection: View {

    // MARK: Lifecycle

    init(group: ActionGroup, type: ActionType, personId: PersistentIdentifier?) {
      self.group = group
      self.type = type

      let groupID = group.persistentModelID
      let typeValue = type.rawValue

      // Show shared actions (no owner) plus any private to the viewed person.
      if let personID = personId {
        _actions = Query(
          filter: #Predicate<Action> { action in
            action.group?.persistentModelID == groupID
              && action.type == typeValue
              && (action.owner == nil || action.owner?.persistentModelID == personID)
          },
          sort: \.name,
        )
      } else {
        _actions = Query(
          filter: #Predicate<Action> { action in
            action.group?.persistentModelID == groupID
              && action.type == typeValue
              && action.owner == nil
          },
          sort: \.name,
        )
      }
    }

    // MARK: Internal

    @Query var actions: [Action]

    var type: ActionType
    var group: ActionGroup

    var body: some View {
      VStack(alignment: .leading, spacing: 8) {
        // The header rides down with scroll to stay pinned just below the tab
        // bar, clamped within its own section so it hands off to the next group.
        // A short gradient below it fades items out as they slide under, so the
        // edge reads soft rather than a hard clip.
        Text(group.name)
          .fontWeight(.medium)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 12)
          .background(.white)
          .overlay(alignment: .bottom) {
            LinearGradient(
              colors: [.white, .white.opacity(0)],
              startPoint: .top,
              endPoint: .bottom,
            )
            .frame(height: 12)
            .offset(y: 12)
            .opacity(fadeOpacity)
            .allowsHitTesting(false)
          }
          .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) { headerHeight = $0 }
          .zIndex(1)
          .offset(y: headerOffset)

        if actions.isEmpty == false {
          VStack(spacing: 8) {
            ForEach(actions) { action in
              Button(action: {
                // TODO: record this action against the current person.
              }) {
                HStack {
                  Text(action.name)

                  Spacer()

                  // Marks an action that is private to this person rather than
                  // shared with the whole family.
                  if action.owner != nil {
                    Image(systemName: "person.fill")
                      .font(.system(size: 11, weight: .semibold))
                      .foregroundStyle(.secondary)
                      .frame(width: 22, height: 22)
                      .background(.white, in: Circle())
                  }

                  MintyUI.CurrencyAmount(action.amount)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(.lightGray)
                .cornerRadius(MintyUI.Radius.standard)
              }
              .buttonStyle(.plain)
            }
          }
        } else {
          Text("No actions found")
        }
      }
      .onGeometryChange(for: CGFloat.self, of: {
        $0.frame(in: .scrollView(axis: .vertical)).minY
      }) { sectionMinY = $0 }
      .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) { sectionHeight = $0 }
    }

    // MARK: Private

    /// Distance below the vertical scroll view's top edge where headers pin,
    /// clearing the pinned tab bar.
    private static let stickyTop: CGFloat = 40

    /// How far the header travels while the fade eases fully in.
    private static let fadeRamp: CGFloat = 12

    @Environment(\.modelContext) private var modelContext

    @State private var sectionMinY: CGFloat = 0
    @State private var sectionHeight: CGFloat = 0
    @State private var headerHeight: CGFloat = 0

    /// Keep the header at `stickyTop` once its section scrolls under the tab bar,
    /// but never push it past its own section's bottom edge.
    private var headerOffset: CGFloat {
      let maxOffset = max(sectionHeight - headerHeight, 0)
      return min(max(Self.stickyTop - sectionMinY, 0), maxOffset)
    }

    /// Fade in only while the header is actually pinned, easing over `fadeRamp`.
    private var fadeOpacity: CGFloat {
      guard headerOffset > 0 else { return 0 }
      return min(max((Self.stickyTop - sectionMinY) / Self.fadeRamp, 0), 1)
    }
  }

  struct ActionsList: View {

    // MARK: Lifecycle

    init(familyId: PersistentIdentifier?, type: ActionType, personId: PersistentIdentifier? = nil) {
      self.type = type
      self.personId = personId

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
    var personId: PersistentIdentifier?

    var body: some View {
      LazyVStack(alignment: .leading, spacing: 28) {
        ForEach(groups) { group in
          ActionsSection(group: group, type: type, personId: personId)
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
