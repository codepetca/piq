# claude.md — Implementation Guide for piq

This file tells AI assistants how to implement and extend **piq**, a minimal guitar practice companion app.
It defines architecture, tech stack, modules, and patterns so changes stay consistent and non‑monolithic.

---

## 1. Project Overview

**App name:** piq  
**Platform:** iOS (iPhone‑first), future watchOS companion  
**Concept:** A calm, minimal app that tells the user what to practice today, in 4 guided blocks, with timers,
simple feedback (Easy/Good/Hard), and light references (diagrams + optional external lessons).

piq is a **practice coach**, not a teaching platform. It schedules and guides practice; it does not contain
full lessons or long written explanations.

### Core Loop

1. User opens app → sees **Today** tab with 4 blocks (Warm‑Up, Song, Solo, Technique).  
2. Taps **Start session** → enters block‑by‑block timed practice.  
3. After each block → answers **How was that? [Easy] [Good] [Hard]**.  
4. At the end → sees a simple session summary.  
5. Over time, a spaced‑repetition engine (SRE) will influence which items appear.

---


## Platform & Framework Constraints (iOS) — CONCISE VERSION

Use modern Apple-native patterns only.

- **Target:** iOS 17+ (iPhone-first).  
- **UI:** SwiftUI only.  
  - Use `NavigationStack`, `TabView`, `.sheet` / `.fullScreenCover`.  
  - Do NOT use `NavigationView`, storyboards, or UIKit unless explicitly required.  
- **State:** Observation framework.  
  - Use `@Observable` classes + `.environment(...)` injection.  
  - Avoid `ObservableObject` + `@Published` except when bridging old APIs.  
- **Async:** Swift Concurrency.  
  - Prefer `async/await` over callbacks.  
  - Use `Task {}` for background work and keep UI updates `@MainActor`.  
- **App Entry:**  
  - `PiqApp` (`@main`) → `RootView` with a `TabView` (Today, History, Settings).  
  - Shared engines (`PracticeEngine`, `HistoryViewModel`, `SettingsViewModel`, etc.) injected via `.environment(...)`.  
- **Frameworks:**  
  - SwiftUI, Observation, Foundation.  
  - AVFoundation/AVAudioEngine ONLY inside `MetronomeService`.  
- **Prohibited by default:**  
  - UIKit components, Combine, Storyboards, NavigationView.  
  - Business logic inside SwiftUI Views.  
- **Composition:**  
  - Use small SwiftUI components.  
  - Engines own logic; Views compose.  
  - No timers in Views (PracticeEngine handles timing).


---

## 3. Repo & Module Structure

High‑level structure (suggested):

```text
/docs
  /core
    claude.md
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

6. **AudioHapticsModule**
   - Services: `MetronomeService`, (optional) `AudioHapticsService`.

7. **WatchModule** (future)
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

Responsibility:
- Draw concentric rings (outer = block, inner = session).
- Show block title and MM:SS timer.
- Handle tap‑to‑pause via callback.

Suggested inputs:

```swift
struct PracticeTimerView: View {
    let title: String
    let timeText: String
    let blockProgress: Double    // 0.0–1.0
    let sessionProgress: Double  // 0.0–1.0
    let isPaused: Bool
    let onTogglePause: () -> Void
    // ...
}
```

No timing logic belongs in `PracticeTimerView`. It is presentational only.

### MetronomeBar

Responsibility:
- Show a metronome toggle and BPM controls in a single horizontal row.
- Use SF Symbol `metronome` instead of text.

Suggested inputs:

```swift
struct MetronomeBar: View {
    let isOn: Bool
    let bpm: Int
    let onToggle: () -> Void
    let onIncreaseBPM: () -> Void
    let onDecreaseBPM: () -> Void
}
```

No AVFoundation logic in this view; it should call into `MetronomeService`
indirectly via callbacks/ViewModel.

### FeedbackBar

Responsibility:
- Display “How was that?” and three feedback options: [Easy] [Good] [Hard].

Inputs:

```swift
struct FeedbackBar: View {
    let onEasy: () -> Void
    let onGood: () -> Void
    let onHard: () -> Void
}
```

No SRE logic in this view.

### BlockListView

Responsibility:
- Display today’s 4 blocks on the Today screen.

Inputs:

```swift
struct BlockListView: View {
    let blocks: [PracticeBlock]
    let onStartSession: () -> Void
}
```

### SongChoiceSheet

Responsibility:
- Modal sheet listing up to 3 song options.

```swift
struct SongOption: Identifiable {
    let id: UUID
    let title: String
}

struct SongChoiceSheet: View {
    let options: [SongOption]
    let onSelect: (SongOption) -> Void
    let onCancel: () -> Void
}
```

### SessionSummaryView

Responsibility:
- Display a completed `PracticeSession` summary with block feedback chips and
  total minutes.

Inputs:

```swift
struct SessionSummaryView: View {
    let session: PracticeSession
    let onClose: () -> Void
}
```

---

## 6. Engine Responsibilities (Single Responsibility)

Engines own logic; Views and ViewModels compose them.

### PracticeEngine

- Owns current `PracticeSession`.  
- Owns current block index and timing state.  
- Exposes a simple state machine, e.g.:
  - `.idle`
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
- Produces “today’s list” of recommended items for session generation.

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
  - SRE state (due dates, etc.) if needed.
- Start simple (UserDefaults / JSON file).  
  SwiftData / CoreData can be added later.

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
   - Basic smoke tests that Today screen renders 4 blocks.  
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
     - Model invariants (e.g. 4 blocks per session, kinds in expected order).
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
   - Wire a basic `generateTodaySession()` that returns 4 blocks.

4. **Phase 3 – Storage**
   - Write tests for `PracticeStorage`:
     - First-run behavior (no sessions saved).
     - Saving and loading a session round-trips correctly.
   - Implement a simple JSON/UserDefaults-based storage layer.

5. **Phase 4 – Wire minimal UI (thin views)**
   - Create `RootView`, `TodayView`, and a very simple `PracticeSessionView`.
   - Do NOT write exhaustive UI tests at this stage.
   - Confirm manually in simulator that:
     - Today shows 4 blocks from engine.
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
- `claude.md` — architecture, modules, platform rules
- `agents.md` — multi-agent roles and responsibilities
- `tests.md` — testing philosophy and priorities

**2. `/docs/guidance/` — High-level domain or feature guidance**
- `piq-guitar-guidance.md` — research-backed guitar-learning model, skill catalog, and SRS concepts
- Future domain or feature guidance files

**3. `/docs/issues/` — Iteration-level tasks**
- Each file in this folder acts as a local "issue" or epic describing a concrete development task for the next cycle.

### Required Reading Order for Any AI Agent Before Modifying Code

1. `/docs/core/design.md`
2. `/docs/core/claude.md`
3. `/docs/core/agents.md`
4. `/docs/core/tests.md`
5. Any relevant file in `/docs/guidance/` (e.g., `piq-guitar-guidance.md`)
6. The specific `/docs/issues/issue-xxx-*.md` file referenced in the current prompt

Agents must always read these files *before* inspecting or modifying source code.
This ensures architectural consistency, avoids design drift, and maintains the intended project workflow.

### Workflow

- The human will update `/docs/guidance/` docs when changing conceptual directions.
- The human will create `/docs/issues/issue-xxx-*.md` docs for each development iteration.
- AI agents must read `core/` → relevant `guidance/` → active `issues/` before coding.
