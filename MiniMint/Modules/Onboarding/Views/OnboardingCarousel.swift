import SwiftUI

struct CarouselItem: Identifiable {
  var id = UUID()
  var text: Text
}

struct OnboardingCarousel: View {
  private let timer = Timer.publish(every: 3.0, on: .main, in: .default).autoconnect()
  
  private var items: [CarouselItem] = [
    CarouselItem(text: Text("Onboarding 1")),
    CarouselItem(text: Text("Onboarding 2")),
    CarouselItem(text: Text("Onboarding 3")),
  ]

  @State private var tabs: [CarouselItem]
  @State private var selectedTab: Int = 1

  public init () {
    var tabs = self.items.map { $0 }

    if let firstItem = self.items.first, let lastItem = self.items.last {
      tabs.append(firstItem)
      tabs.insert(lastItem, at: 0)
    }

    self.tabs = tabs
  }

  var body: some View {
    VStack {
      TabView(selection: self.$selectedTab) {
        ForEach(Array(zip(self.tabs.indices, self.tabs)), id: \.0) { index, item in
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
            selectedTab = self.tabs.count - 2
          }
        } else if selectedTab == self.tabs.count - 1 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            selectedTab = 1
          }
        }
      }

      HStack {
        ForEach(0..<self.items.count, id: \.self) { index in
          Capsule()
            .fill(
              Color("primary_green")
                .opacity((self.selectedTab == self.tabs.count - 1 ? 0 : self.selectedTab - 1) == index ? 1 : 0.12)
            )
            .frame(width: 24, height: 4)
            .onTapGesture {
              self.selectedTab = index
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
}

#Preview {
  OnboardingCarousel()
}
