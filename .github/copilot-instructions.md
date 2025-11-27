# GitHub Copilot Configuration for piq

## Main Instructions

For comprehensive guidance, read the universal AI instructions file:

**`/Users/stew/Repos/vibe/piq/docs/ai-instructions.md`**

This file contains all architecture rules, module boundaries, design patterns, workflows, and testing priorities.

---

## Quick Reference for Inline Suggestions

### Reading Order
1. `docs/core/design.md` → `docs/core/architecture.md` → `docs/core/agents.md` → `docs/core/tests.md`
2. Relevant `docs/guidance/` files
3. Active `docs/issues/issue-*.md` if working on specific task

### Platform Constraints
- **iOS 17+** only (iPhone-first)
- **SwiftUI only** (no UIKit, no Storyboards, no NavigationView)
- **Observation** for state (no Combine, no @Published, no ObservableObject except bridging)
- **Timers in engines only**, never in Views

### Core Loop & State Machine
**Flow:** Today → Start → Block (timer) → Feedback (Easy/Good/Hard) → Next → ... → Summary

**`PracticeEngine.state` drives UI:**
- `.idle` → `.inBlock(index, remainingSeconds)` → `.betweenBlocks(lastIndex, nextIndex)` → `.finished`

Timing lives ONLY in `PracticeEngine` (countdown) and `MetronomeService` (clicks). Views must not create timers.

### Module Boundaries (ios/Modules/)
- **PracticeDomain**: Models (PracticeBlock, PracticeSession), engines (PracticeEngine, SpacedRepetitionEngine), persistence (PracticeStorage)
- **SessionUI**: Screens (TodayView, PracticeSessionView), components (PracticeTimerView, MetronomeBar, FeedbackBar, SessionSummaryView)
- **AudioHapticsModule**: MetronomeService, HapticService (timing & haptics only)
- **HistoryModule / SettingsModule / ReferenceModule**: Thin ViewModels + views; no business logic

Logic never lives in SwiftUI Views. Views compose engines/services via observation.

### Scheduling & SRS
`SpacedRepetitionEngine.generateTodaySession()` builds sessions (warmup first, fun ending last, interleaved middle). Feedback updates item `SRSState` (stability, nextDue). Apply feedback after session: `sre.applyFeedback(for: session.blocks)`.

### UI Composition Rules
SwiftUI only (iOS 17+): `NavigationStack`, `TabView`, `.sheet`. Use Observation (`@Observable`) for shared state injection via `.environment`. Components are stateless presentational views with callbacks.

### Naming Conventions
`referenceID` patterns (match asset names):
- Scale: `scale_<key>_<type>_pos<n>` (e.g., `scale_am_pentatonic_pos3`)
- Chord: `chord_<root>_<quality>_<shape>` (e.g., `chord_g_major_open`)
- Technique: `tech_<category>_<slug>` (e.g., `tech_bends_basic`)
- Licks/Songs: `licks_blues_box1`, `song_<slug>_<section>`

All lowercase, underscore-separated.

### Implementation Patterns
- Create session: `engine.startSession(from: sre)` (preferred) or `engine.startSession()` for demo
- Advance flow: `finishCurrentBlock()` → `recordFeedback(forBlockAt:feedback:)` → `startNextBlock()`
- User actions: `pause()`, `resume()`, `skipCurrentBlock()`, `extendCurrentBlock(byExtraSeconds:)`
- Metronome: `MetronomeService.start()` / `stop()`, `setBPM(_:)`

### Testing Focus
Prioritize engine + storage tests (see `tests.md`). Avoid heavy UI tests; keep Views thin. TDD for `PracticeEngine` and `SpacedRepetitionEngine`. Light UI smoke tests only.

### Do / Avoid
**DO:** Maintain module boundaries; keep engines pure; update docs when changing flows; follow naming conventions; keep views declarative and stateless.

**AVOID:** Adding timers in Views; mixing SRE logic into `PracticeEngine`; storing business logic in ViewModels; large view structs; ad-hoc persistence outside `PracticeStorage`; introducing UIKit/Combine.

---

**For detailed rules, always reference `/docs/ai-instructions.md` and the `/docs/core/` files it points to.**
