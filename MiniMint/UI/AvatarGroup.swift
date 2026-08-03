import SwiftUI

extension MintyUI {
  struct AvatarGroup: View {

    // MARK: Lifecycle

    init(
      people: [Person] = [],
      size: AvatarSize = .medium,
      maxVisible: Int = 3,
    ) {
      self.people = people
      self.size = size
      self.maxVisible = maxVisible
    }

    // MARK: Internal

    var body: some View {
      ZStack {
        ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
          slotView(slot)
            .overlay(
              Circle().stroke(Color.white, lineWidth: ringWidth),
            )
            .offset(offset(for: index, of: slots.count))
            .zIndex(Double(index))
        }

        // Drawn above the avatars so an overlapping dot stays a full circle
        // instead of being clipped by an avatar's white ring.
        ForEach(Array(decorativeDots.enumerated()), id: \.offset) { _, dot in
          Circle()
            .fill(dot.color)
            .frame(width: dot.diameter, height: dot.diameter)
            .offset(dot.offset)
            .zIndex(Double(slots.count))
        }
      }
      .frame(width: containerSize + dotMargin * 2, height: containerSize + dotMargin * 2)
    }

    // MARK: Private

    private enum Slot {
      case person(Person)
      case overflow(Int)
    }

    private let people: [Person]
    private let size: AvatarSize
    private let maxVisible: Int

    private var slots: [Slot] {
      var slots = people.prefix(maxVisible).map(Slot.person)
      let overflow = max(people.count - maxVisible, 0)
      if overflow > 0 {
        slots.append(.overflow(overflow))
      }
      return slots
    }

    /// How far each avatar sits from the cluster's center.
    private var radius: CGFloat {
      slots.count <= 1 ? 0 : size.frameSize * 0.36
    }

    private var containerSize: CGFloat {
      size.frameSize + radius * 2
    }

    /// Extra breathing room around the cluster so the decorative dots have somewhere to sit.
    private var dotMargin: CGFloat {
      size.frameSize * 0.22
    }

    /// Scattered background dots, positioned relative to the cluster center and scaled to the avatar size.
    private var decorativeDots: [(offset: CGSize, diameter: CGFloat, color: Color)] {
      // No dots for a lone avatar — they only read as "confetti" around a cluster.
      guard slots.count > 1 else { return [] }

      let base = size.frameSize
      let palette = Avatar.backgroundOptions.map { Color(hex: $0) }

      func color(_ index: Int) -> Color {
        palette.isEmpty ? Color.gray : palette[index % palette.count]
      }

      // Two avatars sit on a diagonal (top-left / bottom-right), so the dots
      // fill the two empty corners (top-right / bottom-left).
      if slots.count == 2 {
        return [
          (CGSize(width: base * 0.60, height: -base * 0.45), base * 0.20, color(0)),
          (CGSize(width: base * 0.82, height: -base * 0.10), base * 0.13, color(1)),
          (CGSize(width: base * 0.38, height: -base * 0.72), base * 0.14, color(2)),
          (CGSize(width: -base * 0.60, height: base * 0.48), base * 0.24, color(3)),
          (CGSize(width: -base * 0.82, height: base * 0.13), base * 0.13, color(4)),
          (CGSize(width: -base * 0.38, height: base * 0.72), base * 0.14, color(5)),
        ]
      }

      return [
        (CGSize(width: -base * 0.80, height: -base * 0.08), base * 0.30, color(0)),
        (CGSize(width: -base * 0.45, height: -base * 0.75), base * 0.16, color(1)),
        (CGSize(width: base * 0.18, height: -base * 0.82), base * 0.20, color(2)),
        (CGSize(width: base * 0.78, height: -base * 0.04), base * 0.15, color(3)),
        (CGSize(width: -base * 0.25, height: base * 0.78), base * 0.13, color(4)),
      ]
    }

    private var ringWidth: CGFloat {
      size == .small ? 2 : 3
    }

    @ViewBuilder
    private func slotView(_ slot: Slot) -> some View {
      switch slot {
      case let .person(person):
        MintyUI.CircleAvatar(avatar: person.avatar, size: size)
      case let .overflow(count):
        Text("+\(count)")
          .font(.system(size: size.fontSize * 0.5, weight: .bold))
          .foregroundStyle(Color.white)
          .frame(width: size.frameSize, height: size.frameSize)
          .background(Color("primary_green"))
          .clipShape(Circle())
      }
    }

    /// Positions slots evenly around a circle, starting at the top and going clockwise.
    /// Two slots are placed kitty-corner (top-left / bottom-right) instead of stacked.
    private func offset(for index: Int, of count: Int) -> CGSize {
      guard count > 1 else { return .zero }

      let angle: CGFloat = if count == 2 {
        index == 0 ? .pi * 1.25 : .pi * 0.25
      } else {
        -CGFloat.pi / 2 + (2 * .pi / CGFloat(count)) * CGFloat(index)
      }

      return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
    }
  }
}

#Preview {
  let preview = Preview()

  MintyUI.AvatarGroup(
    people: preview.family.people.filter { person in
      person.role == .child
    },
  )
}
