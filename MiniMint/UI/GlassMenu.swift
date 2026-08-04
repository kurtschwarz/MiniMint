import SwiftUI

extension MintyUI {
  // MARK: - GlassMenuItem

  /// One row of a ``MintyUI/GlassMenuModifier`` overflow menu — a labelled
  /// action that can be flagged destructive to tint it red.
  struct GlassMenuItem: Identifiable {

    enum Role {
      case standard
      case destructive
    }

    let id = UUID()
    let title: String
    let systemImage: String
    var role = Role.standard
    let action: () -> Void
  }

  // MARK: - GlassMenu

  /// Shared tuning for the Liquid Glass overflow menu — the button, the panel
  /// it morphs into, and the spring that carries the morph.
  enum GlassMenu {

    // MARK: Internal

    /// The spring the glass rides as it grows from button to panel and back.
    static let animation = Animation.spring(response: 0.38, dampingFraction: 0.8)

    static let buttonSize: CGFloat = 44
    static let panelWidth: CGFloat = 272
    static let dialogWidth: CGFloat = 320
    static let panelRadius: CGFloat = 22

    // MARK: Fileprivate

    /// Shared identity so the collapsed button and expanded panel are treated as
    /// one morphing glass shape.
    fileprivate static let morphID = "minty.glassMenu.morph"
  }

  // MARK: - GlassMenuButtonLabel

  /// The burger glyph, sized to the round button. Glass is applied by the caller
  /// so the same label can front either the morph or the material fallback.
  struct GlassMenuButtonLabel: View {

    let systemImage: String

    var body: some View {
      Image(systemName: systemImage)
        .font(.system(size: 19, weight: .semibold))
        .foregroundStyle(Color("dark_grey"))
        .frame(width: MintyUI.GlassMenu.buttonSize, height: MintyUI.GlassMenu.buttonSize)
        // Swap between the burger and the close glyph without a hard cut.
        .contentTransition(.symbolEffect(.replace))
    }
  }

  // MARK: - GlassMenuRows

  /// The stacked action rows that fill the expanded panel. Glass is applied by
  /// the caller, so this is only the content the glass sits behind.
  struct GlassMenuRows: View {

    // MARK: Internal

    let items: [GlassMenuItem]
    let onSelect: () -> Void

    var body: some View {
      VStack(spacing: 0) {
        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
          Button {
            onSelect()
            item.action()
          } label: {
            row(for: item)
          }
          .buttonStyle(RowStyle())

          if index < items.count - 1 {
            // Run the divider full-width ahead of a destructive row so it reads as
            // a separated section rather than another peer action.
            let separatesDestructive = items[index + 1].role == .destructive
            Divider()
              .overlay(Color("dark_grey").opacity(separatesDestructive ? 0.18 : 0.12))
              .padding(.leading, separatesDestructive ? 0 : 50)
          }
        }
      }
      .frame(width: MintyUI.GlassMenu.panelWidth)
      // Clip the row press-highlights to the panel's rounded corners.
      .clipShape(RoundedRectangle(cornerRadius: MintyUI.GlassMenu.panelRadius, style: .continuous))
    }

    // MARK: Private

    /// Highlights a row while it's held down, mirroring a system menu.
    private struct RowStyle: ButtonStyle {
      func makeBody(configuration: Configuration) -> some View {
        configuration.label
          .background(Color("dark_grey").opacity(configuration.isPressed ? 0.1 : 0))
      }
    }

    private func row(for item: GlassMenuItem) -> some View {
      HStack(spacing: 14) {
        Image(systemName: item.systemImage)
          .font(.system(size: 16, weight: .semibold))
          .frame(width: 22)
        Text(item.title)
          .font(.system(size: 16, weight: .medium))
        Spacer(minLength: 0)
      }
      .foregroundStyle(item.role == .destructive ? Color.red : Color("dark_grey"))
      .padding(.horizontal, 16)
      .padding(.vertical, 13)
      .contentShape(Rectangle())
    }
  }

  // MARK: - GlassMenuModifier

  /// Backs the ``SwiftUICore/View/glassMenu(isPresented:systemImage:alignment:inset:items:)``
  /// modifier: a round glass button that morphs into a glass panel of actions,
  /// à la the GitHub app. Both states share one ``SwiftUICore/GlassEffectContainer``
  /// so the glass fluidly grows from button to panel rather than cross-fading.
  struct GlassMenuModifier: ViewModifier {

    // MARK: Internal

    @Binding var isPresented: Bool

    let systemImage: String
    let alignment: Alignment
    let inset: EdgeInsets
    let items: [GlassMenuItem]

    func body(content: Content) -> some View {
      // A sibling ZStack (rather than an overlay) keeps the pinned button and its
      // panel reliably hit-testable above the screen's scroll content.
      ZStack(alignment: alignment) {
        content

        if isPresented {
          // A faint dim that also closes the menu on any tap outside it.
          Color.black.opacity(0.06)
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture { isPresented = false }
            .transition(.opacity)
        }

        menu()
          .padding(inset)
      }
      .animation(GlassMenu.animation, value: isPresented)
    }

    // MARK: Private

    @Namespace private var namespace

    @ViewBuilder
    private func menu() -> some View {
      if #available(iOS 26.0, *) {
        morphingMenu()
      } else {
        fallbackMenu()
      }
    }

    /// iOS 26: the button and panel share a glass container and a
    /// `glassEffectID`, so toggling between them morphs the glass shape.
    @available(iOS 26.0, *)
    private func morphingMenu() -> some View {
      GlassEffectContainer(spacing: 20) {
        ZStack(alignment: alignment) {
          if isPresented {
            GlassMenuRows(items: items, onSelect: { isPresented = false })
              .glassEffect(
                .regular,
                in: RoundedRectangle(cornerRadius: GlassMenu.panelRadius, style: .continuous),
              )
              .glassEffectID(GlassMenu.morphID, in: namespace)
          } else {
            GlassMenuButtonLabel(systemImage: systemImage)
              .glassEffect(.regular.interactive(), in: Circle())
              .glassEffectID(GlassMenu.morphID, in: namespace)
              .contentShape(Circle())
              .onTapGesture { isPresented = true }
              .accessibilityAddTraits(.isButton)
              .accessibilityLabel("Menu")
          }
        }
      }
    }

    /// Pre–iOS 26: no glass morph available, so the button stays put (toggling to
    /// a close glyph) and the material panel scales out from under it.
    private func fallbackMenu() -> some View {
      ZStack(alignment: alignment) {
        if isPresented {
          GlassMenuRows(items: items, onSelect: { isPresented = false })
            .glassPanel()
            .padding(.top, GlassMenu.buttonSize + 8)
            .transition(
              .scale(scale: 0.86, anchor: .topTrailing).combined(with: .opacity),
            )
        }

        Button { isPresented.toggle() } label: {
          GlassMenuButtonLabel(systemImage: isPresented ? "xmark" : systemImage)
        }
        .buttonStyle(.plain)
        .glassCircle()
        .accessibilityLabel("Menu")
      }
    }
  }
}

extension MintyUI {

  // MARK: Internal

  // MARK: - GlassDialogModifier

  /// Backs the ``SwiftUICore/View/glassConfirmation(isPresented:title:message:confirmTitle:isDestructive:onConfirm:)``
  /// modifier: a centered Liquid Glass confirmation card, styled to match the
  /// overflow menu. Used in place of the system dialog so its width matches.
  struct GlassDialogModifier: ViewModifier {

    // MARK: Internal

    @Binding var isPresented: Bool

    let title: String
    let message: String
    let confirmTitle: String
    let isDestructive: Bool
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
      content
        .overlay {
          ZStack {
            if isPresented {
              // A stronger dim than the menu's — a confirmation should pull focus.
              Color.black.opacity(0.2)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { isPresented = false }
                .transition(.opacity)

              card
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
          }
          .animation(GlassMenu.animation, value: isPresented)
        }
    }

    // MARK: Private

    private var card: some View {
      VStack(spacing: 0) {
        VStack(spacing: 8) {
          Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color("dark_grey"))
          Text(message)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Color("dark_grey").opacity(0.65))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.top, 22)
        .padding(.bottom, 18)

        Divider().overlay(Color("dark_grey").opacity(0.12))

        Button {
          isPresented = false
          onConfirm()
        } label: {
          dialogLabel(confirmTitle, tint: isDestructive ? Color.red : Color("primary_green"), weight: .semibold)
        }
        .buttonStyle(DialogButtonStyle())

        Divider().overlay(Color("dark_grey").opacity(0.12))

        Button { isPresented = false } label: {
          dialogLabel("Cancel", tint: Color("dark_grey"), weight: .medium)
        }
        .buttonStyle(DialogButtonStyle())
      }
      .frame(width: GlassMenu.dialogWidth)
      .clipShape(RoundedRectangle(cornerRadius: GlassMenu.panelRadius, style: .continuous))
      .glassPanel()
    }

    private func dialogLabel(_ text: String, tint: Color, weight: Font.Weight) -> some View {
      Text(text)
        .font(.system(size: 16, weight: weight))
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .contentShape(Rectangle())
    }
  }

  // MARK: Private

  /// Highlights a dialog button while it's held down.
  private struct DialogButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .background(Color("dark_grey").opacity(configuration.isPressed ? 0.1 : 0))
    }
  }
}

// MARK: - View + glassMenu

extension View {

  /// Presents a Liquid Glass confirmation card styled to match ``glassMenu``.
  /// Apply to a screen's root content so the card and its scrim cover the screen.
  func glassConfirmation(
    isPresented: Binding<Bool>,
    title: String,
    message: String,
    confirmTitle: String,
    isDestructive: Bool = false,
    onConfirm: @escaping () -> Void,
  ) -> some View {
    modifier(
      MintyUI.GlassDialogModifier(
        isPresented: isPresented,
        title: title,
        message: message,
        confirmTitle: confirmTitle,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
      ),
    )
  }
}

extension View {

  /// Presents a Liquid Glass overflow menu whose round button morphs into a
  /// panel of actions, anchored to the corner given by `alignment`. Apply this
  /// to a screen's root content so the button, panel, and dismiss scrim sit
  /// above — and escape the clipping of — any scroll view on the screen.
  func glassMenu(
    isPresented: Binding<Bool>,
    systemImage: String = "line.3.horizontal",
    alignment: Alignment = .topTrailing,
    inset: EdgeInsets = EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20),
    items: [MintyUI.GlassMenuItem],
  ) -> some View {
    modifier(
      MintyUI.GlassMenuModifier(
        isPresented: isPresented,
        systemImage: systemImage,
        alignment: alignment,
        inset: inset,
        items: items,
      ),
    )
  }
}

// MARK: - Glass surfaces

extension View {

  /// A circular Liquid Glass surface, falling back to a blurred material on
  /// runtimes before iOS 26.
  @ViewBuilder
  fileprivate func glassCircle() -> some View {
    if #available(iOS 26.0, *) {
      glassEffect(.regular.interactive(), in: Circle())
    } else {
      background(.ultraThinMaterial, in: Circle())
        .overlay(Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
  }

  /// A rounded-rectangle Liquid Glass surface for the menu panel, falling back
  /// to a blurred material on runtimes before iOS 26.
  @ViewBuilder
  fileprivate func glassPanel() -> some View {
    let shape = RoundedRectangle(cornerRadius: MintyUI.GlassMenu.panelRadius, style: .continuous)

    if #available(iOS 26.0, *) {
      glassEffect(.regular, in: shape)
    } else {
      background(.ultraThinMaterial, in: shape)
        .overlay(shape.strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.16), radius: 20, y: 12)
    }
  }
}
