import SwiftData
import SwiftUI

struct PersonView: View {

  // MARK: Lifecycle

  init(
    personId: PersistentIdentifier? = nil,
    person: Person? = nil,
  ) {
    self.personId = personId
    self.person = person
  }

  // MARK: Internal

  @State var person: Person? = nil

  var personId: PersistentIdentifier? = nil

  var activityView: PersonView.ActivityView {
    PersonView.ActivityView(personId: personId)
  }

  var tint: Color {
    if let background = person?.avatar?.background {
      return Color(hex: background)
    }

    return .accentColor
  }

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(alignment: .center, spacing: 0) {
        if let person {
          MintyUI.ChildCard(
            person: person,
            currencyName: person.family?.currency?.name ?? "Coins",
          )
          .onTapGesture {
            if let avatarId = person.avatar?.persistentModelID {
              navigate(
                .sheet(
                  .selectAvatar(avatarId),
                  .large,
                ),
              )
            }
          }
          .padding(.horizontal, 20)

          HStack(spacing: 12) {
            if let personId {
              Button {
                navigate(.sheet(.createAction(personId), .large))
              } label: {
                quickAction("Deposit", systemImage: "arrow.down.left")
              }
              .buttonStyle(.plain)
            }

            Button {
              navigate(.sheet(.createReward, .medium))
            } label: {
              quickAction("Withdraw", systemImage: "arrow.up.right")
            }
            .buttonStyle(.plain)

            Button {
              showAllowance = true
            } label: {
              quickAction(
                "Allowance",
                systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90",
              )
            }
            .buttonStyle(.plain)

            Button {} label: {
              quickAction("More", systemImage: "ellipsis")
            }
            .buttonStyle(.plain)
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 24)
        }

        VStack(alignment: .leading, spacing: 0) {
          sectionHeader("Latest Transactions")
          activityView

          Spacer(minLength: 0)
        }
        .padding(.top, 24)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          UnevenRoundedRectangle(
            topLeadingRadius: MintyUI.Radius.standard,
            topTrailingRadius: MintyUI.Radius.standard,
          )
          .fill(Color.white)
          .padding(.bottom, -1000),
        )
        .background(alignment: .top) {
          UnevenRoundedRectangle(
            topLeadingRadius: MintyUI.Radius.standard,
            topTrailingRadius: MintyUI.Radius.standard,
          )
          .fill(Color.white)
          .frame(height: 40)
          .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: -3)
        }
      }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 5)
        .padding(.bottom, 20)
        .frame(minHeight: proxy.size.height)
      }
      .scrollContentBackground(.hidden)
      .hideTopScrollEdgeEffect()
      .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
    .background {
      Color(hex: 0xF7F7F7)
        .ignoresSafeArea()
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(
          action: {
            dismiss()
          },
        ) {
          Image(systemName: "chevron.left")
        }
        .tint(toolbarTintColor)
        .accessibilityLabel("Back")
      }

      ToolbarItem(placement: .principal) {
        if let person {
          TextField("Name", text: Binding(
            get: { person.name },
            set: { person.name = $0 },
          ))
          .font(.system(size: 18, weight: .bold))
          .multilineTextAlignment(.center)
          .keyboardType(.asciiCapable)
          .disableAutocorrection(true)
          .submitLabel(.done)
          .focused($isEditingName)
          .onSubmit(commitName)
        } else {
          Text("Unknown")
            .font(.system(size: 18, weight: .bold))
        }
      }

    }
    .navigationBarBackButtonHidden(true)
    .toolbarTitleDisplayMode(.inline)
    .onAppear(perform: loadPerson)
    .onChange(of: isEditingName) { _, editing in
      if !editing {
        commitName()
      }
    }
    .onChange(of: person?.avatar?.background) { _, newValue in
      if newValue != nil {
        toolbarTintColor = Color(hex: newValue!)
          .adjust(saturation: 0.30, brightness: -0.35)
      }
    }
    .sheet(isPresented: $showAllowance) {
      if let person {
        AllowanceView(person: person)
          .presentationDetents([.large])
      }
    }
    }
  }

  func quickAction(_ title: String, systemImage: String) -> some View {
    VStack(spacing: 10) {
      Image(systemName: systemImage)
        .font(.system(size: 22, weight: .regular))
        .foregroundStyle(Color.black)
        .frame(width: 64, height: 64)
        .background(Color.white, in: Circle())

      Text(title)
        .font(.system(size: 15, weight: .regular))
        .foregroundStyle(Color.black)
    }
    .frame(maxWidth: .infinity)
  }

  func sectionHeader(_ title: String) -> some View {
    Text(title)
      .font(.system(size: 18, weight: .bold))
      .foregroundStyle(Color("dark_grey"))
      .padding(.horizontal, 20)
      .padding(.top, 10)
  }

  func loadPerson() {
    if personId != nil, person == nil {
      person = modelContext.model(for: personId!) as? Person
    }

    committedName = person?.name ?? ""
  }

  /// Trim and persist the edited name, restoring the last committed value when
  /// the field is left empty.
  func commitName() {
    guard let person else {
      return
    }

    let trimmed = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      person.name = committedName
      return
    }

    person.name = trimmed
    committedName = trimmed

    try? modelContext.save()
  }

  // MARK: Private

  @State private var toolbarTintColor = Color.primaryGreen
  @State private var committedName = ""
  @State private var showAllowance = false

  @FocusState private var isEditingName: Bool

  @Environment(\.modelContext) private var modelContext
  @Environment(\.navigate) private var navigate
  @Environment(\.dismiss) private var dismiss
  @Environment(StateManager.self) private var stateManager: StateManager
}

extension View {
  /// Removes the soft scroll-edge blur SwiftUI applies at the top edge on
  /// iOS 26+, leaving a hard (blur-free) edge.
  @ViewBuilder
  func hideTopScrollEdgeEffect() -> some View {
    if #available(iOS 26.0, *) {
      scrollEdgeEffectStyle(.soft, for: .top)
    } else {
      self
    }
  }

  /// Clips the view into a circle with a Liquid Glass background on iOS 26+,
  /// falling back to an ultra-thin material on earlier releases.
  @ViewBuilder
  func quickActionGlass() -> some View {
    let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)

    if #available(iOS 26.0, *) {
      glassEffect(.regular, in: shape)
    } else {
      background(.ultraThinMaterial, in: shape)
    }
  }
}

#Preview {
  let preview = Preview()

  NavigationStack {
    PersonView(
      personId: preview.family.people.first?.persistentModelID,
    )
  }
  .environment(preview.stateManager)
  .modelContainer(preview.modelContainer)
}
