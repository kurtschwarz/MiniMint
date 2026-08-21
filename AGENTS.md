# AGENTS.md

MiniMint is a native iOS app for tracking a family's chore-and-reward economy. Parents ("Adults") define actions that earn or spend a custom in-app currency, and children ("Littles") accrue balances through a ledger of recorded actions.

## Tech stack

- **Language:** Swift 6.1 (`.swift-version`); project sets `SWIFT_VERSION = 5.0` in build settings.
- **UI:** SwiftUI, `preferredColorScheme(.light)` app-wide.
- **Persistence:** SwiftData (`@Model` classes).
- **Deployment target:** iOS 18.4.
- **Bundle ID:** `ca.minimint.MiniMint`.
- **Build system:** Xcode project (`MiniMint.xcodeproj`), no SPM/CocoaPods.

## Build & test

Common tasks are wrapped in the [`justfile`](justfile) (run `just` to list them):

```bash
# Build the app for the simulator
just build

# Run unit + UI tests
just test

# Build, install, and launch on the booted simulator
just run
```

## Running & driving the simulator

- Use the **mobile-mcp** tools to control the iPhone simulator (launch, tap, screenshot, inspect view hierarchy) rather than driving the UI by hand.
- Prefer testing on an **iPhone 17 running iOS 26+** by default; fall back to another available simulator only when that device is not present.
- **Always reload the simulator once all code changes are complete** so the running app reflects the latest build (e.g. `just run`, which builds, installs, and relaunches on the booted simulator).

## Project structure

```
MiniMint/
├── App.swift                 # @main entry, NavigationStack + route→view switch
├── Info.plist, *.entitlements, PrivacyInfo.xcprivacy
├── Managers/
│   ├── StateManger.swift     # StateManager: navigation, current Family, setup state (note: filename is misspelled)
│   └── SwiftDataManager.swift# Shared ModelContainer / schema registration
├── Models/                   # SwiftData @Model types (see below)
├── Modules/                  # Feature screens, one folder per feature
│   ├── Home/                 # Family dashboard (Adults / Littles lists)
│   ├── Onboarding/           # First-run carousel
│   ├── Setup/                # Family/Currency/Children setup flow + coordinator
│   ├── Person/               # Person detail with Actions/Rewards/Activity sub-views
│   ├── Actions/              # Create action
│   ├── Rewards/              # Create reward
│   └── Avatar/               # Select / edit avatar
├── UI/                       # Reusable views under the `MintyUI` namespace
├── Extensions/               # Foundation/SwiftUI extensions
├── Helpers/                  # Preview harness, math helpers
└── Assets.xcassets/          # Colors, avatars, currency/family name datasets, images
```

## Architecture

- **Navigation is centralized in `StateManager`** (`Managers/StateManger.swift`), an `@Observable` injected via `.environment(...)`. It owns the `NavigationStack` `path`, the presented `sheet`, and setup state. Screens navigate by calling `navigate(type:)` with a `NavigationType` (`.push` / `.unwind` / `.back` / `.sheet`) rather than pushing views directly.
- **Routes** are enumerated in `Route` (`Managers/StateManger.swift`). `App.view(route:)` maps each `Route` case to its view. To add a screen: add a `Route` case, handle it in `App.view(route:)`, and navigate to it via the environment's `navigate` action.
- **`hasCompletedSetup`** decides the initial view (`HomeView` vs `OnboardingView`). The active `Family`'s `PersistentIdentifier` is persisted to `UserDefaults` under `"familyId"` and rehydrated on launch by `StateManager.restore()`.
- **`NullStateManager`** is the no-op default for the environment / previews.

## Data model

Root aggregate is `Family`, which owns everything via cascade-delete relationships:

- **`Family`** — name, `avatar`, `currency`, `people`, `actionGroups`, `actions`. Default `ActionGroup`s are generated on init (Chores, Physical, Cognitive, Social/Emotional, Creative).
- **`Person`** — `name`, `role` (`.parent` / `.child`), `balance`, `avatar`, `ledger`.
- **`Currency`** — the family's named in-app currency (unique name, with avatar).
- **`Action`** — a named deposit/withdrawal (`ActionType`) of an `amount`, belonging to a `Family` and optionally an `ActionGroup`.
- **`ActionGroup`** — a category grouping `Action`s.
- **`Ledger` / `LedgerEntry`** — per-person history; each entry references the `Action` performed and a date.
- **`Avatar`** — emoji/symbol/image + background color; `Codable` and seeded from JSON datasets in `Assets.xcassets`.

All models are registered in `SwiftDataManager`'s `Schema`. In DEBUG previews the container is in-memory (`XCODE_RUNNING_FOR_PREVIEWS`).

## Conventions

- **Formatting:** SwiftFormat with Airbnb rules (`.swiftformat`). Key rules: 2-space indent, `self` removed where redundant, trailing commas always, `MARK:` organization (`// MARK: Lifecycle`, `// MARK: Internal`, `// MARK: Private`, etc.), visibility-ordered members, testable imports sorted to bottom. Run SwiftFormat before committing.
- **Reusable UI** lives in the `MintyUI` namespace (`UI/UI.swift`), e.g. `MintyUI.PeopleList`.
- **Previews** use the `Preview` helper (`Helpers/Preview.swift`) to supply an in-memory model container and a seeded `StateManager`.
- **Commit style:** Conventional Commits (`fix:`, `feat:`, …) as seen in git history.

## Skills

Reusable agent skills live in `.agents/skills/` (exposed as `.claude/skills/` via a symlink so Claude Code auto-discovers them).

- **`creating-commits`** — load [`.agents/skills/creating-commits/SKILL.md`](.agents/skills/creating-commits/SKILL.md) before making any commit. All commits in this repo must be Conventional Commits, cryptographically signed (`git commit -S`), and end with `Co-Authored-By: Claude (<MODEL>) <noreply@anthropic.com>`.
- **`writing-skills`** — load [`.agents/skills/writing-skills/SKILL.md`](.agents/skills/writing-skills/SKILL.md) before authoring, restructuring, or reviewing any skill. It defines the naming (gerund form), frontmatter, progressive-disclosure, and metadata conventions, and bundles a validator (`scripts/validate-metadata.py`), a template (`assets/SKILL.template.md`), and a review checklist (`references/checklist.md`).
