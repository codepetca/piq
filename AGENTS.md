# Repository Guidelines

## Project Structure & Module Organization
- iOS app lives in `ios/` with SwiftUI screens (`PracticeSessionView.swift`, `TodayView.swift`, `SettingsView.swift`, `RootView.swift`) and assets in `Assets.xcassets`.
- Domain logic is in `ios/Modules/PracticeDomain` (engine/state, session generation, tempo learning) and companion modules for reference data (`ios/Modules/ReferenceModule`) and UI components (`ios/Modules/SessionUI`).
- Tests sit in `ios/Tests`, split by domain (`PracticeDomainTests`), Today module, and reference module. Swift Package targets are defined in `Package.swift`.
- Docs live under `docs/` for workflow, design, and issue templates.

## Build, Test, and Development Commands
- `open ios/Piq.xcodeproj` — launch the app workspace in Xcode.
- `xcodebuild -scheme Piq -destination 'platform=iOS Simulator,name=iPhone 15' build` — headless build.
- `swift test` — run package tests (PracticeDomain/Today/Reference) from the repo root.
- `xed .` is fine for quick Xcode launches; simulators target iOS 17+.

## Coding Style & Naming Conventions
- Swift 5.9, SwiftUI-first. Prefer structs, value semantics, and @Observable/@Environment injection used in existing views.
- Indent with 4 spaces (Xcode default). Keep view bodies small; extract subviews/helpers when branches grow.
- Naming follows the module: `PracticeEngine`, `PracticeSessionView`, `MetronomeBar`. Use PascalCase for types, camelCase for vars/functions, and imperative names for actions (`handleMetronomeForBlock`).
- Comments are minimal and purpose-driven; avoid repeating what the code already states.

## Testing Guidelines
- Framework: XCTest. Place new tests alongside their module in `ios/Tests/<Module>Tests`.
- Name tests descriptively (`test...`) and cover engine state changes, timers, and UI logic where possible.
- Run `swift test` (or Xcode test actions) before pushing; prefer fast domain tests for quick validation.

## Commit & Pull Request Guidelines
- Commits: concise, imperative/sentence-style summaries (e.g., “Refine session metronome control and time adjustments”).
- PRs: link the relevant GitHub issue, summarize behavior changes, list test evidence (`swift test`, simulator runs), and include screenshots/GIFs for UI tweaks.
- Branches generally follow `issue/<id>-short-description` (e.g., `issue/62-session-ui-tweaks`).

## Security & Configuration Tips
- No secrets are stored in the repo; keep API keys/config out of source. Use Xcode environment settings or local config files ignored by Git.
- Audio/haptics rely on simulator/device permissions—verify on-device for anything timing-critical.
