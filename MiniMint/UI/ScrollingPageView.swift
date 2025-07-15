import Foundation
import SwiftUI

extension MintyUI {

  // MARK: - PageLabel

  struct PageLabel: Codable, Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    init(title: String) {
      self.title = title
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
      case title
    }

    let id = UUID()
    let title: String

  }

  // MARK: - PageLabelBuilder

  @resultBuilder
  struct PageLabelBuilder {
    static func buildBlock(_ components: PageLabel...) -> [PageLabel] {
      return components.compactMap { $0 }
    }
  }

  // MARK: - ScrollingPageView

  struct ScrollingPageView<Header: View, Pages: View>: View {

    // MARK: Lifecycle

    init(
      tint: Color = .accentColor,
      @ViewBuilder header: @escaping () -> Header,
      @PageLabelBuilder labels: @escaping () -> [PageLabel],
      @ViewBuilder pages: @escaping () -> Pages,
      onRefresh: @escaping () async -> Void = { },
    ) {
      self.header = header()
      self.labels = labels()
      self.pages = pages()
      self.tint = tint
      self.onRefresh = onRefresh

      let count = labels().count
      _scrollPositions = .init(initialValue: .init(repeating: .init(), count: count))
      _scrollGeometries = .init(initialValue: .init(repeating: .init(), count: count))
      _activeTab = State(initialValue: labels().first?.title)
    }

    // MARK: Internal

    var header: Header
    var labels: [PageLabel]
    var pages: Pages
    var onRefresh: () async -> Void

    var body: some View {
      ZStack(alignment: .top) {
        GeometryReader {
          let size = $0.size

          Rectangle()
            .frame(
              maxWidth: .infinity,
              maxHeight: calculateBackgroundHeight(proxy: $0),
            )
            .foregroundStyle(self.tint.adjust(opacity: -0.5))
            .ignoresSafeArea(.all, edges: .top)

          ScrollView(.horizontal) {
            HStack(spacing: 0) {
              Group(subviews: pages) { collection in
                ForEach(labels, id: \.title) { label in
                  pageView(label: label, size: size, collection: collection)
                }
              }
            }
            .scrollTargetLayout()
          }
          .scrollTargetBehavior(.paging)
          .scrollPosition(id: $activeTab)
          .scrollIndicators(.hidden)
          .scrollContentBackground(.hidden)
          .scrollDisabled(mainScrollDisabled)
          .allowsHitTesting(mainScrollPhase == .idle)
          .onScrollPhaseChange { _, newPhase in
            mainScrollPhase = newPhase
          }
          .onScrollGeometryChange(for: ScrollGeometry.self, of: {
            $0
          }, action: { _, newValue in
            mainScrollGeometry = newValue
          })
          .mask {
            Rectangle()
              .ignoresSafeArea(.all, edges: .bottom)
          }
        }
      }
    }

    var horizontalScrollDisableGesture: some Gesture {
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          mainScrollDisabled = true
        }
        .onEnded { _ in
          mainScrollDisabled = false
        }
    }

    @ViewBuilder func pageView(
      label: PageLabel,
      size: CGSize,
      collection: SubviewsCollection,
    ) -> some View {
      let index = labels.firstIndex(where: { $0.title == label.title }) ?? 0

      ScrollView(.vertical) {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
          ZStack {
            if activeTab == label.title {
              header
                .visualEffect { content, proxy in
                  content
                    .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                }
                .onGeometryChange(for: CGFloat.self) {
                  $0.size.height
                } action: { newValue in
                  headerHeight = newValue
                }
                .transition(.identity)
            } else {
              Rectangle()
                .foregroundStyle(.clear)
                .frame(height: headerHeight)
                .transition(.identity)
            }
          }
          .simultaneousGesture(horizontalScrollDisableGesture)

          Section {
            collection[index]
              .frame(maxWidth: .infinity, minHeight: size.height - 35, alignment: .top)
              .background(.clear)
          } header: {
            ZStack {
              if activeTab == label.title {
                tabBar()
                  .visualEffect { content, proxy in
                    content
                      .offset(x: -proxy.frame(in: .scrollView(axis: .horizontal)).minX)
                  }
                  .transition(.identity)
              } else {
                Rectangle()
                  .foregroundStyle(.clear)
                  .frame(height: 40)
                  .transition(.identity)
              }
            }
            .simultaneousGesture(horizontalScrollDisableGesture)
          }
        }
      }
      .onScrollGeometryChange(
        for: ScrollGeometry.self,
        of: { $0 },
        action: { _, newValue in
          scrollGeometries[index] = newValue

          if newValue.offsetY < 0 {
            resetScrollViews(label)
          }
        }
      )
      .scrollPosition($scrollPositions[index])
      .onScrollPhaseChange { _, newPhase in
        let geometry = scrollGeometries[index]
        let maxOffset = min(geometry.offsetY, headerHeight)

        if newPhase == .idle && maxOffset <= headerHeight {
          updateOtherScrollViews(label, to: maxOffset)
        }

        if newPhase == .idle && mainScrollDisabled {
          mainScrollDisabled = false
        }
      }
      .frame(width: size.width)
      .scrollClipDisabled()
      .refreshable {
        await onRefresh()
      }
      .zIndex(activeTab == label.title ? 1000 : 0)
    }

    @ViewBuilder func tabBar() -> some View {
      let progress = max(min(mainScrollGeometry.offsetX / mainScrollGeometry.containerSize.width, CGFloat(labels.count - 1)), 0)

      VStack(alignment: .leading, spacing: 5) {
        HStack(spacing: 0) {
          ForEach(labels, id: \.title) { label in
            Group {
              Text(label.title)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(
              activeTab == label.title ? self.tint.adjust(
                saturation: 0.30,
                brightness: -0.35,
              ) : .black
            )
            .onTapGesture {
              withAnimation(.easeInOut(duration: 0.25)) {
                activeTab = label.title
              }
            }
          }
        }
        .frame(maxHeight: .infinity)

        ZStack(alignment: .leading) {
          Capsule()
            .frame(width: 50, height: 2)
            .containerRelativeFrame(.horizontal) { value, _ in
              value / CGFloat(labels.count)
            }
            .visualEffect { content, proxy in
              content
                .offset(x: proxy.size.width * progress, y: 0)
            }
            .foregroundStyle(
              self.tint.adjust(
                saturation: 0.30,
                brightness: -0.35,
              )
            )
        }
      }
      .frame(height: 40)
      .coordinateSpace(name: "tabBar")
      .background {
        Rectangle().fill(.white)
        Rectangle()
          .fill(self.tint.adjust(opacity: -0.5))
      }
    }

    func resetScrollViews(_ from: PageLabel) {
      for index in labels.indices {
        let label = labels[index]
        if label.title != from.title {
          scrollPositions[index].scrollTo(y: 0)
        }
      }
    }

    func updateOtherScrollViews(_ from: PageLabel, to: CGFloat) {
      for index in labels.indices {
        let label = labels[index]
        let offset = scrollGeometries[index].offsetY

        let wantsUpdate = offset < headerHeight || to < headerHeight
        if wantsUpdate && label.title != from.title {
          scrollPositions[index].scrollTo(y: to)
        }
      }
    }

    // MARK: Private

    @State private var activeTab: String?
    @State private var headerHeight: CGFloat = 0
    @State private var scrollGeometries: [ScrollGeometry]
    @State private var scrollPositions: [ScrollPosition]

    @State private var mainScrollDisabled = false
    @State private var mainScrollPhase = ScrollPhase.idle
    @State private var mainScrollGeometry = ScrollGeometry()

    private var tint: Color

    private func calculateBackgroundHeight(
      proxy: GeometryProxy,
    ) -> CGFloat {
      let minHeight = 40.0 + proxy.safeAreaInsets.top
      let baseHeight = headerHeight + minHeight
      let pageIndex = labels.firstIndex(where: { $0.title == activeTab }) ?? 0

      return max(
        baseHeight - scrollGeometries[pageIndex].offsetY,
        minHeight,
      )
    }

  }
}

extension ScrollGeometry {

  // MARK: Lifecycle

  fileprivate init() {
    self.init(contentOffset: .zero, contentSize: .zero, contentInsets: .init(.zero), containerSize: .zero)
  }

  // MARK: Fileprivate

  fileprivate var offsetY: CGFloat {
    contentOffset.y + contentInsets.top
  }

  fileprivate var offsetX: CGFloat {
    contentOffset.x + contentInsets.leading
  }
}

#Preview {
  MintyUI.ScrollingPageView(
    tint: Color(hex: 0xEEE0FF),
  ) {
    VStack {
      Text("Header")
    }
    .frame(maxWidth: .infinity)
  } labels: {
    MintyUI.PageLabel(title: "Activity")
    MintyUI.PageLabel(title: "Actions")
    MintyUI.PageLabel(title: "Rewards")
  } pages: {
    Text("Activity Page")
    Text("Actions Page")
    Text("Rewards Page")
  }
}
