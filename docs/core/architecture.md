# architecture.md — Implementation Guide for piq

This file tells AI assistants how to implement and extend **piq**, a minimal guitar practice companion app.
It defines architecture, tech stack, modules, and patterns so changes stay consistent and non‑monolithic.

---

## 1. Project Overview

**App name:** piq  
**Platform:** iOS (iPhone‑first), future watchOS companion  
**Concept:** A calm, minimal app that tells the user what to practice today, in 6–8 guided microblocks, with timers,
simple feedback (Easy/Good/Hard), and light references (diagrams + optional external lessons).

piq is a **practice coach**, not a teaching platform. It schedules and guides practice; it does not contain
full lessons or long written explanations.

### Core Loop

1. User opens app → sees the **Today** screen with 6–8 microblocks (Warm‑Up first, interleaved middle, fun ending).  
2. Taps **Start session** → enters a 10s preview then block‑by‑block timed practice.  
3. After each block → answers **How was that? [Easy] [Good] [Hard]**.  
4. At the end → sees a simple session summary.  
5. Over time, a spaced‑repetition engine (SRE) will influence which items appear.

---


## Platform & Framework Constraints (iOS)

**Target:** iOS 17+ (iPhone-first). **UI:** SwiftUI only (NavigationStack, sidebar menu overlay, .sheet/.fullScreenCover). **State:** Observation (@Observable + .environment). **Async:** Swift Concurrency (async/await, Task{}, @MainActor for UI). **App Entry:** PiqApp (@main) → RootView → NavigationStack with a hamburger-triggered sidebar controlling routes (Today, Profile, History, Settings). Engines injected via .environment. **Frameworks:** SwiftUI, Observation, Foundation. AVFoundation/AVAudioEngine only in MetronomeService.

**Rules:** Small composable views. Engines own logic/timers, Views compose. **Prohibited:** UIKit, Combine, Storyboards, NavigationView, ObservableObject (except bridging old APIs), business logic in Views, timers in Views.


---

## 3. Repo & Module Structure

High‑level structure (suggested):

```text
/docs
  /core
    architecture.md
    design.md
    agents.md
    tests.md
  /guidance
    piq-guitar-guidance.md
  /issues
    (iteration-level task files)

/ios
  PiqApp.swift
  RootView.swift

  /Modules
    /PracticeDomain
    /SessionUI
    /ReferenceModule
    /HistoryModule
    /SettingsModule
    /AudioHapticsModule
    /WatchModule (future)
```

### Core Modules (Do Not Monolith)

All new code and features must fit into one of these modules. Do **not** create god objects or giant views.

1. **PracticeDomain**
   - Models: `PracticeBlock`, `PracticeBlockKind`, `PracticeSession`,
     `PracticeItem`, `PracticeBlockFeedback`.
   - Engines: `PracticeEngine`, `SpacedRepetitionEngine`.
   - Services: `PracticeStorage` (simple persistence).

2. **SessionUI**
   - Screens: `TodayView`, `PracticeSessionView`, `SessionSummaryView`.
   - Components: `PracticeTimerView`, `MetronomeBar`, `FeedbackBar`,
     `BlockListView`, `SongChoiceSheet`.

3. **ReferenceModule**
   - Models: `PracticeReference`.
   - Services: `PracticeReferenceService`.
   - Screens: `PracticeReferenceView`.

4. **HistoryModule**
   - ViewModels: `HistoryViewModel`.
   - Screens: `HistoryView`, `SessionDetailView`.

5. **SettingsModule**
   - ViewModels: `SettingsViewModel`.
   - Screens: `SettingsView`.
   - (Future) simple content/library management for songs, diagrams.

6. **OnboardingModule**
   - ViewModels: `OnboardingViewModel`.
   - Screens: `OnboardingView` (coordinator), `WelcomeStepView`, `LevelStepView`,
     `StylesStepView`, `CuesStepView`, `OnboardingSummaryView`.
   - Handles first-launch preference collection only; thin UI layer over
     PracticeDomain `UserPreferences`.
   - Preview session uses `PracticeSession.makeOnboardingPreview()` to demonstrate
     actual session generation based on selected preferences.

7. **AudioHapticsModule**
   - Services: `MetronomeService`, (optional) `AudioHapticsService`.

8. **WatchModule** (future)
   - watchOS SwiftUI views mirroring the timer UI.
   - Connectivity helpers to share state.

When adding a feature, decide first: **which module does this belong to?**

---

## 4. Core Domain Concepts

### PracticeBlockKind

Enum describing the 4 main block types:

- `warmup`
- `song`
- `solo`
- `techniqueOrTheory`

Each has a short `displayName` (e.g. “Warm‑Up”, “Song”, “Solo”, “Technique”).

### PracticeBlock

Represents a single block in a session:

- `id: UUID`
- `kind: PracticeBlockKind`
- `title: String` (short)
- `detail: String` (optional, short)
- `targetMinutes: Int`
- `actualMinutes: Int?`
- `key: String?` (e.g. "Am")
- `practiceItemID: UUID?` (link to SRE item, later)
- `feedback: PracticeBlockFeedback?` (`easy`, `good`, `hard`)
- `referenceID: String?` (e.g. `scale_am_pentatonic_pos1`)

### PracticeSession

- `id: UUID`
- `date: Date`
- `[PracticeBlock]`
- `totalMinutes` (computed or stored)

### PracticeBlockFeedback

Enum: `.easy`, `.good`, `.hard`.  
Used for future SRE decisions.

### PracticeReference

Small model for reference diagrams (scales, chords, techniques):

- `id: String` (e.g. `scale_am_pentatonic_pos1`)
- `title: String` (short)
- `assetName: String` (same as `id`)
- `externalURL: URL?` (optional YouTube/lesson link)

Naming and asset rules are defined in `design.md`.

---

## 5. SwiftUI Components (Reuse These)

piq’s UI must be composed of small SwiftUI components. Do not put complex layout
or business logic directly into screen views.

### PracticeTimerView

Presentational only. Displays concentric rings (outer=block, inner=session), title, MM:SS timer. Accepts progress values (0.0-1.0), pause state, pause callback. No timing logic.

### MetronomeBar

Single horizontal row with metronome toggle (SF Symbol `metronome`), BPM value, +/- controls. Accepts on/off state, BPM int, toggle/increase/decrease callbacks. No AVFoundation logic.

### FeedbackBar

Displays "How was that?" with three buttons: [Easy] [Good] [Hard]. Accepts three callbacks. No SRE logic.

### BlockListView

Displays today's 6–8 microblocks on Today screen. Accepts blocks array, start session callback.

### SongChoiceSheet

Modal sheet with up to 3 song options. Accepts song options array (id, title), select callback, cancel callback.

### SessionSummaryView

Displays completed session summary with block feedback and total minutes. Accepts session object, close callback.

---

## 6. Engine Responsibilities (Single Responsibility)

Engines own logic; Views and ViewModels compose them.

### PracticeEngine

- Owns current `PracticeSession`.  
- Owns current block index and timing state.  
- Exposes a simple state machine, e.g.:
  - `.idle`
  - `.previewBlock(index: Int, secondsRemaining: Int)`
  - `.inBlock(index: Int, remainingSeconds: Int)`
  - `.betweenBlocks(lastIndex: Int, nextIndex: Int?)`
  - `.finished`
- Methods:
  - `startSession()`, `startBlock(at:)`
  - `finishCurrentBlock()`, `skipCurrentBlock()`
  - `extendCurrentBlock(byExtraSeconds:)`
  - `recordFeedback(forBlockAt:feedback:)`

PracticeEngine does **not**:
- Implement spaced‑repetition scheduling.
- Play sounds or haptics.
- Know about SwiftUI.

### SpacedRepetitionEngine

- Owns scheduling of `PracticeItem`s:
  - Next due times
  - Difficulty/ease factors
- Consumes feedback signals (Easy/Good/Hard) on blocks/items.
- Produces “today’s list” of recommended items for session generation (6–8 microblocks; warmup first, interleaved middle, fun ending; suggested BPM for metronome-on blocks).

SpacedRepetitionEngine does **not**:
- Own UI or timers.
- Know about `PracticeSession` layout.

### MetronomeService

- Owns metronome click generation (AVAudioEngine, timers).  
- Exposes simple APIs:
  - `start(bpm:)`
  - `stop()`
  - `setBPM(_:)`

MetronomeService does **not**:
- Contain SwiftUI.
- Know about SRE or block kinds.

### PracticeStorage

- Handles persistence for:
  - Completed `PracticeSession`s.
  - Light user preferences (level, styles, cues).  
  - SRE/tempo state (due dates, BPM history).
- Merges seed catalog with stored SRS/tempo on load; saves updated sessions/items after each session via `PracticeEngine.onSessionFinished`.
- Start simple (UserDefaults / JSON file). SwiftData / CoreData can be added later.

---

## 7. Timer Rule (Important)

SwiftUI Views must **not** create or manage `Timer` instances for practice timing.

- All block countdown logic lives in `PracticeEngine`.  
- Views observe engine state (`state`, `remainingSeconds`).  
- Pausing/resuming is done via methods on `PracticeEngine`, not local timers.  
- Metronome timing lives in `MetronomeService`, not in Views.

If a new feature appears to need time‑based behavior, first check whether it belongs
in `PracticeEngine` or `MetronomeService` before introducing new timers.

---

## 8. Patterns for Adding New Features

### Add a New Practice Block Type

1. Add a new case to `PracticeBlockKind`.  
2. Update any mapping functions that generate labels or defaults.  
3. Update `PracticeEngine`’s session generation to include the new block where appropriate.  
4. Update `BlockListView` to show the new block.  
5. Update `PracticeSessionView` if the block needs unique UI behavior.  
6. Add tests for the new flow in `PracticeEngine`.

### Add a New Reference Diagram

1. Create an asset using naming conventions in `design.md`.  
2. Add a corresponding `PracticeReference` in `PracticeReferenceService`.  
3. Attach its `id` to `referenceID` for any relevant `PracticeBlock`/`PracticeItem`.  
4. Confirm that `PracticeSessionView` shows the `questionmark.circle` icon and opens the sheet.

### Extend Spaced Repetition Behavior

1. Modify `SpacedRepetitionEngine` only.
2. Use `PracticeBlockFeedback` or item‑level data as the input.
3. Do not move SRE logic into Views or `PracticeEngine`.
4. Add tests to validate new scheduling behavior.

### Add a New Swift File

When creating a new Swift file in the `ios/Modules/` directory:

1. Create the `.swift` file in the appropriate module folder.
2. Add the file to `Package.swift` in the appropriate target's `sources:` array.
3. **CRITICAL: Add the file to `ios/Piq.xcodeproj/project.pbxproj`** (required for Xcode builds).
   - Can be edited directly by AI assistants following existing UUID patterns
   - Or added manually in Xcode: right-click module folder → Add Files to "Piq"
4. Build in Xcode (Cmd+B) to confirm no "Cannot find 'X' in scope" errors.

**Note:** Swift Package Manager builds (`swift build`) will work without step 3, but Xcode builds will fail with scope errors.

---

## 9. Testing Strategy

Testing should focus on **core logic first**, then light UI tests.

### Priorities

1. **Unit tests for PracticeEngine**
   - Block timing transitions (`start`, `finish`, `skip`, `extend`).  
   - Correct `state` transitions.  
   - Recording feedback and actual minutes.

2. **Unit tests for SpacedRepetitionEngine**
   - Given sequences of feedback (Easy/Good/Hard), verify due dates/ordering.  
   - Ensure easy items appear less frequently, hard items more frequently.

3. **Unit tests for PracticeStorage**
   - Save/load sessions and preferences.  
   - Handle empty / first‑run cases gracefully.

4. **Light UI tests / snapshots (optional)**
   - Basic smoke tests that Today screen renders generated microblocks (6–8).  
   - Practice screen shows timer and buttons.  
   - Feedback screen shows 3 choices.

### TDD Recommendation

- For **PracticeEngine** and **SpacedRepetitionEngine**, a light TDD style is encouraged:
  - Write tests for state transitions and scheduling behavior first or in parallel.  
  - Keep engines pure and deterministic to make tests easy.
- For SwiftUI views, do not force strict TDD; prefer:
  - Small, composable views.  
  - Manual inspection plus occasional snapshot tests.

Focus TDD effort where the logic is complex (timing, SRE). Keep UI flexible.


### TDD Development Flow for the MVP

Use this rough sequence when building out the first version of piq:

1. **Phase 0 – Domain skeleton (no UI yet)**
   - Define core models: `PracticeBlockKind`, `PracticeBlock`, `PracticeSession`, `PracticeBlockFeedback`.
   - Add simple factory helpers (e.g. `PracticeSession.makeTodayDemo()`).
   - Tests:
     - Model invariants (e.g. warmup-first ordering, fun ending last, total microblocks within 6–8).
     - Basic derived properties (e.g. total minutes).

2. **Phase 1 – PracticeEngine (driven by tests)**
   - Write tests for the state machine *before* implementation:
     - `startSession()` puts engine into first `.inBlock`.
     - Tick/advance logic updates `remainingSeconds` correctly.
     - `finishCurrentBlock()` moves to `.betweenBlocks` and then to next block.
     - `skipCurrentBlock()` skips correctly without breaking state.
     - `extendCurrentBlock(by:)` adds time as expected.
   - Implement `PracticeEngine` to satisfy tests.
   - Keep engine UI-agnostic.

3. **Phase 2 – SpacedRepetitionEngine (stub then grow)**
   - Start with tests for a simple heuristic:
     - Newly seen items appear more often.
     - Items marked Easy appear less frequently.
     - Items marked Hard appear more frequently.
   - Implement minimal `SpacedRepetitionEngine` that passes these tests.
   - Wire a basic `generateTodaySession()` that returns 6–8 microblocks (warmup first, interleaved middle, fun ending).

4. **Phase 3 – Storage**
   - Write tests for `PracticeStorage`:
     - First-run behavior (no sessions saved).
     - Saving and loading a session round-trips correctly.
   - Implement a simple JSON/UserDefaults-based storage layer.

5. **Phase 4 – Wire minimal UI (thin views)**
   - Create `RootView`, `TodayView`, and a very simple `PracticeSessionView`.
   - Do NOT write exhaustive UI tests at this stage.
   - Confirm manually in simulator that:
     - Today shows generated microblocks from engine.
     - Starting a session moves engine to `.inBlock`.
     - Timer updates the view via observation.

6. **Phase 5 – Add components & refine UI**
   - Extract `PracticeTimerView`, `MetronomeBar`, `FeedbackBar`, `SongChoiceSheet`.
   - Keep these views **stateless/presentational** with callbacks.
   - Only add UI tests for critical flows (start session → complete session).

7. **Phase 6 – Iterate on SRE and history**
   - As SRE logic grows, always:
     - Write tests for new scheduling behavior first.
     - Keep UI unchanged where possible.
   - Add tests for `HistoryViewModel` showing correct sessions list.

The general rule:
- **Engines and storage:** strongly favor TDD.  
- **UI:** keep views small and rely on manual testing + a few smoke UI tests.


---

## 10. Future Extensions (Must Stay Modular)

### watchOS App

- Implement in `WatchModule`.  
- Reuse conceptual components:
  - compact `PracticeTimerView`  
  - simple buttons for pause/skip  
- Share state via a small shared model or connectivity.  
- Do not re‑implement timing logic on watch; reuse domain concepts.

### Additional Block Types

- Add new `PracticeBlockKind` cases.  
- Update session generation and UI components.  
- Keep the number of blocks per day small and consistent (e.g. always 4).

### Deeper SRE

- Extend `SpacedRepetitionEngine` only.  
- Keep UI and feedback interaction the same (Easy/Good/Hard).  
- Update `design.md` if SRE changes user‑visible behavior.

---

## 11. Documentation Layout & Reading Order

piq's documentation is organized into three layers:

**1. `/docs/core/` — Stable reference docs**
- `design.md` — UI/UX and flows
- `architecture.md` — architecture, modules, platform rules
- `agents.md` — multi-agent roles and responsibilities
- `tests.md` — testing philosophy and priorities

**2. `/docs/guidance/` — High-level domain or feature guidance**
- `guidance.md` — research-backed guitar-learning model, skill catalog, and SRS concepts
- Future domain or feature guidance files

**3. `/docs/issues/` — Iteration-level tasks**
- Each file in this folder acts as a local "issue" or epic describing a concrete development task for the next cycle.

### Required Reading Order for Any AI Agent Before Modifying Code

1. `/docs/core/design.md`
2. `/docs/core/architecture.md`
3. `/docs/core/agents.md`
4. `/docs/core/tests.md`
5. Any relevant file in `/docs/guidance/` (e.g., `guidance.md`)
6. The specific `/docs/issues/issue-xxx-*.md` file referenced in the current prompt

Agents must always read these files *before* inspecting or modifying source code.
This ensures architectural consistency, avoids design drift, and maintains the intended project workflow.

### Workflow

- The human will update `/docs/guidance/` docs when changing conceptual directions.
- The human will create `/docs/issues/issue-xxx-*.md` docs for each development iteration.
- AI agents must read `core/` → relevant `guidance/` → active `issues/` before coding.
