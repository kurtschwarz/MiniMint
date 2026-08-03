import SwiftData
import SwiftUI

extension MintyUI {
  struct PeopleList: View {

    // MARK: Lifecycle

    init(
      people: [Person] = [],
      showAddPersonButton: Bool = false,
      showBalance: Bool = true,
      isEditing: Binding<Bool> = .constant(false),
    ) {
      self.people = people
      self.showAddPersonButton = showAddPersonButton
      self.showBalance = showBalance
      _isEditing = isEditing
    }

    // MARK: Internal

    var body: some View {
      ScrollView(.horizontal) {
        LazyHStack(alignment: .top, spacing: spacing) {
          ForEach(Array(orderedPeople.enumerated()), id: \.element.persistentModelID) { index, person in
            personCell(person, index: index)
          }

          if showAddPersonButton {
            addButton
          }
        }
        .fixedSize(horizontal: false, vertical: true)
        .onPreferenceChange(CellWidthPreferenceKey.self) { widths = $0 }
      }
      // Let a lifted avatar render past the row's bounds instead of being clipped.
      .scrollClipDisabled()
      // Let the drag rearrange cells instead of scrolling the row while editing.
      .scrollDisabled(isEditing)
      .onAppear { syncOrder() }
      .onChange(of: people.map(\.persistentModelID)) { _, _ in syncOrder() }
    }

    // MARK: Private

    @Environment(\.navigate) private var navigate
    @Environment(\.modelContext) private var modelContext

    @Binding private var isEditing: Bool
    @State private var orderedPeople: [Person] = []

    // Drag state. The array is left untouched until the drop; the lifted cell
    // follows the finger via `dragTranslation`, and the rest shift by one slot.
    @State private var draggingPerson: Person?
    @State private var dragStartIndex: Int?
    @State private var dragTargetIndex = 0
    @State private var dragTranslation: CGSize = .zero
    @State private var slotStride: CGFloat = 72
    @State private var widths: [PersistentIdentifier: CGFloat] = [:]

    private let spacing: CGFloat = 8

    private var people: [Person] = []
    private var showAddPersonButton = false
    private var showBalance = true

    private var addButton: some View {
      Button(action: { }) {
        Image(systemName: "plus")
          .font(.system(size: 24, weight: .regular))
          .foregroundStyle(Color("dark_grey"))
      }
      .buttonStyle(PlainButtonStyle())
      .frame(width: 64, height: 64)
      .background(.lightGray)
      .cornerRadius(32)
    }

    @ViewBuilder
    private func personCell(_ person: Person, index: Int) -> some View {
      let isDragging = draggingPerson?.persistentModelID == person.persistentModelID

      VStack(alignment: .center, spacing: 0) {
        if person.avatar != nil {
          MintyUI.CircleAvatar(
            avatar: person.avatar!,
            size: .medium,
          )
        }

        Text(person.name)
          .font(.system(size: 14, weight: .bold))
          .padding(.top, 10)
          .padding(.bottom, 2)

        if showBalance {
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
      .background(
        GeometryReader { geometry in
          Color.clear.preference(
            key: CellWidthPreferenceKey.self,
            value: [person.persistentModelID: geometry.size.width],
          )
        },
      )
      .scaleEffect(isDragging ? 1.08 : 1)
      .offset(offset(for: person, at: index))
      .zIndex(isDragging ? 1 : 0)
      .onTapGesture {
        // In edit mode taps are inert — reordering is a drag, and Done exits.
        guard !isEditing else { return }
        navigate(.push(.person(person.persistentModelID)))
      }
      .onLongPressGesture(minimumDuration: 0.4) {
        guard !isEditing else { return }
        withAnimation { isEditing = true }
      }
      // The reorder drag is only live in edit mode; otherwise the row scrolls
      // normally. `highPriorityGesture` beats the ScrollView's pan so the drag
      // actually reorders; the GestureMask disables it (letting the row scroll)
      // when not editing, and keeps taps/long-presses working.
      .highPriorityGesture(dragGesture(for: person, at: index), including: isEditing ? .all : .subviews)
    }

    /// Where a cell should visually sit during a drag: the lifted cell tracks the
    /// finger, and cells between the source and target slots slide over by one slot.
    private func offset(for person: Person, at index: Int) -> CGSize {
      guard let source = dragStartIndex, draggingPerson != nil else { return .zero }

      if draggingPerson?.persistentModelID == person.persistentModelID {
        return dragTranslation
      }

      if source < dragTargetIndex, index > source, index <= dragTargetIndex {
        return CGSize(width: -slotStride, height: 0)
      }

      if source > dragTargetIndex, index >= dragTargetIndex, index < source {
        return CGSize(width: slotStride, height: 0)
      }

      return .zero
    }

    /// Reorder drag, active only in edit mode (gated by the caller's GestureMask).
    /// A plain `DragGesture` — no long-press sequencing — so it never competes with
    /// the tap/long-press gestures used to open a person or enter edit mode.
    private func dragGesture(for person: Person, at index: Int) -> some Gesture {
      DragGesture(minimumDistance: 8)
        .onChanged { drag in
          if draggingPerson == nil {
            startDrag(person, at: index)
          }
          guard let source = dragStartIndex, slotStride > 0 else { return }

          dragTranslation = drag.translation

          let shift = Int((drag.translation.width / slotStride).rounded())
          let target = min(max(source + shift, 0), orderedPeople.count - 1)
          if target != dragTargetIndex {
            withAnimation(.snappy) { dragTargetIndex = target }
          }
        }
        .onEnded { _ in commitReorder() }
    }

    private func startDrag(_ person: Person, at index: Int) {
      draggingPerson = person
      dragStartIndex = index
      dragTargetIndex = index
      dragTranslation = .zero
      slotStride = (widths[person.persistentModelID] ?? 64) + spacing
    }

    /// Apply the single reorder and settle every cell back to a zero offset in one
    /// animation, so the final layout matches what was on screen — no snap-back.
    private func commitReorder() {
      guard let source = dragStartIndex else {
        clearDrag()
        return
      }

      let target = dragTargetIndex

      withAnimation(.snappy) {
        if target != source {
          orderedPeople.move(
            fromOffsets: IndexSet(integer: source),
            toOffset: target > source ? target + 1 : target,
          )
        }
        clearDrag()
      }

      persistOrder()
    }

    private func clearDrag() {
      draggingPerson = nil
      dragStartIndex = nil
      dragTranslation = .zero
    }

    /// Mirror the incoming (already-sorted) people unless a drag is mid-flight.
    private func syncOrder() {
      guard draggingPerson == nil else { return }
      orderedPeople = people
    }

    /// Persist the current visual order back onto each person's `sortOrder`.
    private func persistOrder() {
      for (index, person) in orderedPeople.enumerated() where person.sortOrder != index {
        person.sortOrder = index
      }

      try? modelContext.save()
    }

  }

  // MARK: - CellWidthPreferenceKey

  private struct CellWidthPreferenceKey: PreferenceKey {
    static let defaultValue: [PersistentIdentifier: CGFloat] = [:]

    static func reduce(
      value: inout [PersistentIdentifier: CGFloat],
      nextValue: () -> [PersistentIdentifier: CGFloat],
    ) {
      value.merge(nextValue()) { _, new in new }
    }
  }
}

#Preview {
  let preview = Preview()

  MintyUI.PeopleList(
    people: preview.family.people.filter { person in
      person.role == .child
    },
    showAddPersonButton: true,
  )
}
