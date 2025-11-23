# agents.md — Multi‑Agent Roles for piq

This file defines how different AI "agents" (or modes) should collaborate
on the piq codebase. The goal is to keep the architecture modular, avoid
monolithic changes, and respect design and platform rules.

All agents must follow:
- UX + flow rules in `design.md`
- Architecture + platform rules in `claude.md`

---

## Platform Discipline

All agents must respect the platform constraints in `claude.md`:

- SwiftUI‑only UI (`NavigationStack`, `TabView`, `.sheet`).  
- Observation (`@Observable`, `.environment(...)`) for shared state.  
- Swift Concurrency (`async/await`) for async work.  
- No UIKit, storyboards, or Combine unless explicitly documented as an exception.

If proposed code uses outdated patterns (e.g. `NavigationView`, `ObservableObject` for new types),
it should be refactored to follow the platform section in `claude.md`.

---

## Architect Agent

**Focus:** System design, module boundaries, avoiding monoliths.

Responsibilities:
- Owns and enforces the Module Map defined in `claude.md`.  
- Decides where new features belong (PracticeDomain, SessionUI, etc.).  
- Ensures:
  - No god objects or giant view models.
  - No business logic in SwiftUI Views.
  - Engines own logic; views compose engines.
- Proposes refactors when files become too large or cross concerns.

Must not:
- Implement UI details (that’s UI/UX Agent’s job).  
- Add business logic directly in Views.

---

## UI/UX Agent

**Focus:** Screens, layout, and components following `design.md`.

Works mainly in:
- `SessionUI`
- `HistoryModule`
- `SettingsModule`
- `ReferenceModule`

Responsibilities:
- Build and refine SwiftUI screens using the component set from `claude.md`:
  - `PracticeTimerView`
  - `MetronomeBar`
  - `FeedbackBar`
  - `BlockListView`
  - `SongChoiceSheet`
  - `SessionSummaryView`
- Follow **minimal UI** rules:
  - Few words, no subtitles, max 3 options where possible.
  - Use SF Symbols (e.g. `metronome`, `questionmark.circle`, `gear`, `guitars`).  
- Ensure flows match `design.md` (onboarding, Today, session loop, History, Settings).

Must not:
- Introduce timers, audio logic, or SRE logic in Views.  
- Change the conceptual flow without updating `design.md`.

---

## Logic Agent

**Focus:** Core domain and engine behavior.

Works in:
- `PracticeDomain`
- `SpacedRepetitionEngine`
- `AudioHapticsModule`
- `PracticeStorage`

Responsibilities:
- Maintain and evolve `PracticeEngine`:
  - Session creation and block ordering.
  - State machine (idle, inBlock, betweenBlocks, finished).
  - Timing logic and feedback recording.
- Maintain and evolve `SpacedRepetitionEngine`:
  - Use feedback signals (Easy/Good/Hard) to schedule items.  
  - Keep it independent of SwiftUI.
- Maintain `MetronomeService`:
  - Audio timing for clicks, possibly haptics.
- Ensure no business logic leaks into SwiftUI Views.

Must not:
- Modify SwiftUI layout or visual details except for minimal wiring.  
- Add persistence logic outside `PracticeStorage`.

---

## Data/Storage Agent

**Focus:** Persistence & data shape over time.

Works primarily in:
- `PracticeStorage`
- Any future persistence layer

Responsibilities:
- Design simple, version‑safe persistence for:
  - Completed sessions.
  - User preferences (level, styles, cues).  
  - SRE state if needed.
- Implement migrations when models evolve.  
- Keep storage APIs simple and engine‑friendly.

Must not:
- Embed business rules or UI concerns in storage code.

---

## Audio/Haptics Agent

**Focus:** Metronome sound and optional haptic feedback.

Works in:
- `AudioHapticsModule`

Responsibilities:
- Implement and maintain `MetronomeService`:
  - Stable tick timing for given BPM.  
  - Start/stop/setBPM operations.
- Optionally add light haptic pulses for downbeats.  
- Keep APIs simple so UI + Logic Agents only need to call high‑level methods.

Must not:
- Implement UI or navigation.  
- Put audio logic in SwiftUI views.

---

## Refactor Agent (Optional)

**Focus:** Ongoing maintainability.

Responsibilities:
- Identify oversized Views or ViewModels and propose splits.  
- Ensure engines remain focused on one concern each.  
- Suggest extraction of new components (e.g., new small SwiftUI views) when duplication appears.

Must:
- Preserve behavior and flows defined in `design.md`.  
- Keep changes small, well‑scoped, and incremental.

---

## Testing/QA Agent

**Focus:** Ensuring correctness via tests.

Responsibilities:
- Design and maintain unit tests for:
  - `PracticeEngine` state transitions and timing.  
  - `SpacedRepetitionEngine` scheduling behavior.  
  - `PracticeStorage` saving/loading logic.
- 
- Coordinate with the Logic Agent to follow the "TDD Development Flow for the MVP"
  defined in `claude.md`:
  - Start from models → PracticeEngine → SpacedRepetitionEngine → Storage.
  - Keep engines small, deterministic, and easy to test.
Propose lightweight UI tests where valuable:
  - Today screen renders 4 blocks.  
  - Practice screen navigates through block → feedback → next block.
- Encourage a light TDD style for core logic (engines) where feasible.

Must not:
- Change user‑visible behavior without coordination with Architect + UI/UX Agents.

---

## Recommended File Reading Order for Agents

When starting a new task:

1. Read `design.md` to understand flows, components, and visual rules.  
2. Read `claude.md` for architecture, modules, and platform constraints.  
3. Skim existing Swift code in the affected module(s).  
4. Then implement or refactor with minimal, focused changes.
