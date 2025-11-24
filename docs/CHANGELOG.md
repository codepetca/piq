# Changelog

All notable changes to piq are documented in this file.

---

## [0.1.0] - 2024-11-23

### Initial MVP Release

Complete implementation of core practice companion functionality following TDD approach.

#### Phase 0 - Domain Skeleton
- Define core models: `PracticeBlockKind`, `PracticeBlock`, `PracticeSession`, `PracticeBlockFeedback`
- Add factory helpers and model invariants
- Unit tests for model properties

#### Phase 1 - PracticeEngine
- Implement state machine (`idle`, `inBlock`, `betweenBlocks`, `finished`)
- Timer control with `tick()`, `pause()`, `resume()`
- Block transitions: `startBlock()`, `finishCurrentBlock()`, `skipCurrentBlock()`, `extendCurrentBlock()`
- Feedback recording per block
- 39 unit tests passing

#### Phase 2 - SpacedRepetitionEngine
- SM-2 based scheduling algorithm
- Item prioritization (overdue → new → by due date)
- Feedback processing (Easy/Good/Hard adjusts intervals)
- Session generation from prioritized items
- Unit tests for scheduling behavior

#### Phase 3 - PracticeStorage
- JSON file-based persistence
- Save/load sessions and items
- ISO8601 date encoding
- First-run detection and clear all data
- Unit tests for storage round-trips

#### Phase 4 - Minimal UI
- `PiqApp` entry point with environment injection
- `RootView` with TabView (Today, History, Settings)
- `TodayView` displaying 4 blocks from SRE
- `PracticeSessionView` with timer and state handling

#### Phase 5 - UI Components
- Extract `PracticeTimerView` with concentric progress rings
- Create `FeedbackBar` with Easy/Good/Hard buttons
- Create `MetronomeBar` with toggle and BPM controls
- Create `SongChoiceSheet` for song selection
- Move timer management from View to `PracticeEngine`
- Refactor `PracticeSessionView` to use components

#### Phase 6 - History Module & SRE Feedback
- `HistoryViewModel` with session management and statistics
- `HistoryView` with grouped sessions, stats row, swipe-to-delete
- `SessionDetailView` for viewing individual sessions
- Wire SRE feedback on session completion
- Persist updated SRE items after feedback
- 11 unit tests for HistoryViewModel

#### Post-MVP Additions
- `MetronomeService` with AVAudioEngine click generation
- `SettingsViewModel` with UserDefaults persistence
- `SettingsView` with preferences and data management actions

---

## Summary

- **Total Swift files:** 23
- **Total lines of code:** ~3,000
- **Test coverage:** PracticeEngine, SpacedRepetitionEngine, PracticeStorage, HistoryViewModel
- **Architecture:** SwiftUI + Observation framework, @Observable engines, environment injection
