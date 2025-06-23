import SwiftUI

// MARK: - CarouselItem

struct CarouselItem: Identifiable {
  var id = UUID()
  var text: Text
}

// MARK: - OnboardingCarousel

struct OnboardingCarousel: View {

  // MARK: Lifecycle

  public init() {
    var tabs = items.map(\.self)

    if let firstItem = items.first, let lastItem = items.last {
      tabs.append(firstItem)
      tabs.insert(lastItem, at: 0)
    }

    self.tabs = tabs
  }

  // MARK: Internal

  var body: some View {
    VStack {
      TabView(selection: $selectedTab) {
        ForEach(Array(zip(tabs.indices, tabs)), id: \.0) { index, item in
          VStack {
            item.text
          }
          .tag(index)
        }
      }
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      .ignoresSafeArea()
      .onChange(of: selectedTab) {
        if selectedTab == 0 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedTab = tabs.count - 2
          }
        } else if selectedTab == tabs.count - 1 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedTab = 1
          }
        }
      }

      HStack {
        ForEach(0 ..< items.count, id: \.self) { index in
          Capsule()
            .fill(
              Color("primary_green")
                .opacity((selectedTab == tabs.count - 1 ? 0 : selectedTab - 1) == index ? 1 : 0.12),
            )
            .frame(width: 24, height: 4)
            .onTapGesture {
              selectedTab = index
            }
        }
      }
    }
    .frame(height: 300)
//    .onReceive(timer) { _ in
//      withAnimation(.default) {
//        self.selected = (self.selected + 1) % self.items.count
//      }
//    }
  }

  // MARK: Private

  @State private var tabs: [CarouselItem]
  @State private var selectedTab = 1

  private let timer = Timer.publish(every: 3.0, on: .main, in: .default).autoconnect()

  private var items: [CarouselItem] = [
    CarouselItem(text: Text("Onboarding 1")),
    CarouselItem(text: Text("Onboarding 2")),
    CarouselItem(text: Text("Onboarding 3")),
  ]
}

#Preview {
  OnboardingCarousel()
}
