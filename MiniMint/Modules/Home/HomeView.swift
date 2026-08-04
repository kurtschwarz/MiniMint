import SwiftData
import SwiftUI

// MARK: - HomeView

struct HomeView: View {

  // MARK: Internal

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        // Heading + summary sit on a grey backdrop that runs up under the status bar.
        VStack(spacing: 0) {
          HStack(alignment: .center, spacing: 16) {
            MintyUI.AvatarGroup(
              people: littles,
            )

            VStack(alignment: .leading, spacing: 0) {
              Text("the")
                .font(.system(size: 14, weight: .medium))
              Text(stateManager.family?.name ?? "")
                .font(.system(size: 28, weight: .bold, design: .serif))
              Text("family")
                .font(.system(size: 14, weight: .medium))
            }
            .multilineTextAlignment(.leading)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.bottom, 20)

          childCardsCarousel
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
        // The sheet below overlaps up by the corner radius; add it back so the visible
        // grey gap under the cards stays a full 24 rather than being eaten by the overlap.
        .padding(.bottom, MintyUI.Radius.standard)
        .frame(maxWidth: .infinity)
        // Let the wash bleed up into the status-bar area so the top blends seamlessly.
        .background(heroBackground, ignoresSafeAreaEdges: .top)

        // The rest of the content rides on a white sheet with rounded top corners.
        VStack(spacing: 0) {
          summaryCard

          recentActivitySection
            .padding(.top, 32)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 20)
        // Restore the height the upward pull below borrows back from the layout.
        .padding(.bottom, MintyUI.Radius.standard)
        .frame(maxWidth: .infinity)
        .background(
          UnevenRoundedRectangle(
            topLeadingRadius: MintyUI.Radius.standard,
            topTrailingRadius: MintyUI.Radius.standard,
          )
          .fill(Color.white),
        )
        // Pull the sheet up so its rounded corners overlap the grey hero and read against it.
        .padding(.top, -MintyUI.Radius.standard)
      }
    }
    .toolbar(content: {
//      ToolbarItem(placement: .topBarTrailing) {
//        Button(
//          action: { },
//          label: {
//            Image(systemName: "bell.badge")
//              .foregroundStyle(.red, Color("primary_green"))
//          },
//        )
//      }
//
//      ToolbarItem(placement: .topBarTrailing) {
//        Button(
//          action: { },
//          label: {
//            Image(systemName: "person")
//              .foregroundStyle(Color("primary_green"))
//          },
//        )
//      }
    })
    .scrollIndicators(.hidden)
    // White base so everything below the sheet — including the bottom safe area — reads white.
    .background(Color.white, ignoresSafeAreaEdges: .all)
    .navigationBarBackButtonHidden(true)
  }

  // MARK: Private

  @Environment(\.modelContext) private var modelContext
  @Environment(\.navigate) private var navigate
  @Environment(StateManager.self) private var stateManager: StateManager

  /// Gap between cards, and — set equal to the card's side peek — the leading and
  /// trailing scroll margin that lets the first and last cards rest centered too.
  private let cardSpacing: CGFloat = 12
  private let cardPeek: CGFloat = 10

  /// A very subtle wash behind the heading: white at the top so it melts into the
  /// status-bar area, easing down into grey above the white sheet below.
  private var heroBackground: LinearGradient {
    LinearGradient(
      colors: [Color.white, Color("light_gray")],
      startPoint: .top,
      endPoint: .bottom,
    )
  }

  private var littles: [Person] {
    people(role: .child)
  }

  /// Currency held across all the Littles — the family's money in play.
  private var totalInCirculation: Int64 {
    littles.reduce(0) { $0 + $1.balance }
  }

  private var currencyName: String {
    stateManager.family?.currency?.name ?? "coins"
  }

  /// The newest ledger entries across the whole family, most recent first.
  private var recentActivity: [ActivityItem] {
    (stateManager.family?.people ?? [])
      .flatMap { person in
        (person.ledger?.entries ?? []).map { ActivityItem(person: person, entry: $0) }
      }
      .sorted { ($0.entry.date ?? .distantPast) > ($1.entry.date ?? .distantPast) }
      .prefix(5)
      .map { $0 }
  }

  /// The family's money at a glance, sitting just under the family header.
  private var summaryCard: some View {
    HStack(spacing: 14) {
      if let avatar = stateManager.family?.currency?.avatar {
        MintyUI.CircleAvatar(avatar: avatar, size: .medium)
      } else {
        Image("coin_icon")
          .resizable()
          .frame(width: 44, height: 44)
      }

      VStack(alignment: .leading, spacing: 2) {
        MintyUI.CurrencyAmount(totalInCirculation, size: 26)
        Text("\(currencyName) in circulation")
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(Color("dark_grey").opacity(0.7))
      }

      Spacer(minLength: 0)
    }
    .padding(16)
    .frame(maxWidth: .infinity)
    .background(Color("light_gray"))
    .cornerRadius(MintyUI.Radius.standard)
  }

  /// A swipeable, peeking row of one card per Little, trailed by an add card.
  private var childCardsCarousel: some View {
    ScrollView(.horizontal) {
      // A plain HStack (not lazy): with a handful of cards there's no laziness to
      // gain, and a LazyHStack unloads a card the moment it crosses the viewport
      // edge — which, with clipping disabled, makes it pop instead of scroll out.
      HStack(spacing: cardSpacing) {
        ForEach(littles) { person in
          MintyUI.ChildCard(person: person, currencyName: currencyName)
            .containerRelativeFrame(.horizontal, count: 20, span: 19, spacing: cardSpacing)
            .contentShape(RoundedRectangle(cornerRadius: MintyUI.Radius.standard, style: .continuous))
            .onTapGesture { navigate(.push(.person(person.persistentModelID))) }
        }

        addChildCard
          .containerRelativeFrame(.horizontal, count: 20, span: 19, spacing: cardSpacing)
      }
      .scrollTargetLayout()
    }
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden)
    // Symmetric margins equal to the side peek let every card — including the
    // first and last — rest centered, so the row opens on the first card and
    // each one settles evenly instead of drifting toward the middle.
    .contentMargins(.horizontal, cardPeek, for: .scrollContent)
    // Let each card's drop shadow spill past the row instead of being clipped.
    .scrollClipDisabled()
  }

  private var addChildCard: some View {
    Button(action: { navigate(.sheet(.createPerson(.child))) }) {
      VStack(spacing: 10) {
        Image(systemName: "plus")
          .font(.system(size: 26, weight: .regular))
        Text("Add a little")
          .font(.system(size: 14, weight: .semibold))
      }
      .foregroundStyle(Color("dark_grey"))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        RoundedRectangle(cornerRadius: MintyUI.Radius.standard, style: .continuous)
          .strokeBorder(Color("dark_grey").opacity(0.18), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
          .background(Color("light_gray").opacity(0.5), in: RoundedRectangle(cornerRadius: MintyUI.Radius.standard, style: .continuous)),
      )
    }
    .buttonStyle(.plain)
    .aspectRatio(1.586, contentMode: .fit)
  }

  private var recentActivitySection: some View {
    Section(
      header: HStack {
        Text("Recent Activity")
          .font(.system(size: 16, weight: .bold))
        Spacer()
      },
    ) {
      if recentActivity.isEmpty {
        activityEmptyState
      } else {
        VStack(spacing: 16) {
          ForEach(recentActivity) { item in
            MintyUI.ActivityRow(entry: item.entry, person: item.person)
          }
        }
        .padding(.top, 14)
      }
    }
  }

  private var activityEmptyState: some View {
    VStack(spacing: 6) {
      Image(systemName: "sparkles")
        .font(.system(size: 30))
        .foregroundStyle(Color("primary_green").opacity(0.5))
        .padding(.bottom, 2)
      Text("No activity yet")
        .font(.system(size: 15, weight: .semibold))
      Text("Tap a kid to record their first chore.")
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(Color("dark_grey").opacity(0.6))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 36)
  }

  private func people(role: Role) -> [Person] {
    (stateManager.family?.people ?? [])
      .filter { $0.role == role }
      .sorted { ($0.sortOrder, $0.name) < ($1.sortOrder, $1.name) }
  }
}

// MARK: - ActivityItem

/// Pairs a ledger entry with the person it belongs to, since an entry only
/// links back to its `Ledger`.
private struct ActivityItem: Identifiable {
  let person: Person
  let entry: LedgerEntry

  var id: PersistentIdentifier { entry.persistentModelID }
}

#Preview {
  let preview = Preview()

  NavigationStack {
    HomeView()
  }
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
