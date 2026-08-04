import SwiftData
import SwiftUI

// MARK: - SetupCoordinator

@Observable class SetupCoordinator {

  // MARK: Lifecycle

  init(stateManager: StateManager? = nil, modelContext: ModelContext? = nil) {
    self.stateManager = stateManager
    self.modelContext = modelContext
  }

  // MARK: Internal

  var currentStep = Step.createFamily

  var family = Family()
  var currency = Currency()
  var people: [Person] = [
    .init(name: "", role: .child, avatar: Avatar.generate()),
  ]

  /// Whether the current step is complete enough to move on.
  var canAdvance: Bool {
    switch currentStep {
    case .addChildren:
      return people.allSatisfy {
        !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      }
    default:
      return true
    }
  }

  @ObservationIgnored() var stateManager: StateManager? = nil
  @ObservationIgnored() var modelContext: ModelContext? = nil
}

// MARK: SetupCoordinator.Step

extension SetupCoordinator {

  enum Step: Int, CaseIterable {
    case createFamily
    case createCurrency
    case addChildren

    // MARK: Internal

    var nextButtonLabel: String {
      switch self {
      case .createFamily: return "Next"
      case .createCurrency: return "Next"
      case .addChildren: return "Complete"
      }
    }
  }

  @ViewBuilder
  func currentStepView() -> some View {
    switch currentStep {
    case .createFamily:
      SetupFamilyView(setupCoordinator: self)
    case .createCurrency:
      SetupCurrencyView(setupCoordinator: self)
    case .addChildren:
      SetupChildrenView(setupCoordinator: self)
    }
  }

  func nextStep() {
    guard currentStep.rawValue < Step.allCases.count - 1 else {
      return complete()
    }

    currentStep = Step(rawValue: currentStep.rawValue + 1)!
  }

  func previousStep() {
    guard currentStep.rawValue > 0 else {
      guard let stateManager else {
        return
      }

      return stateManager.navigate(type: .back)
    }

    currentStep = Step(rawValue: currentStep.rawValue - 1)!
  }

  func complete() {
    guard let stateManager else {
      return
    }

    guard let modelContext else {
      return
    }

    try? modelContext.transaction {
      for (index, person) in people.enumerated() {
        person.name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        person.sortOrder = index
      }

      family.people = people
      family.currency = currency
      let actionGroups = ActionGroup.generateDefaults()
      family.actionGroups = actionGroups
      family.actions = actionGroups.flatMap(\.actions)

      modelContext.insert(family)

      do {
        try modelContext.save()

        stateManager.familyId = family.persistentModelID
        stateManager.family = family

        stateManager.navigate(type: .push(.home))
      } catch {
        return
      }
    }
  }
}
