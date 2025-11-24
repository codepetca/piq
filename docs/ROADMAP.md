# Roadmap

This document tracks the development plan for piq.

---

## Completed

### Phase 0 - Domain Skeleton ✅
- [x] Define core models
- [x] Factory helpers
- [x] Unit tests for invariants

### Phase 1 - PracticeEngine ✅
- [x] State machine implementation
- [x] Timer control (tick, pause, resume)
- [x] Block transitions
- [x] Feedback recording
- [x] Comprehensive unit tests

### Phase 2 - SpacedRepetitionEngine ✅
- [x] SM-2 based scheduling
- [x] Item prioritization
- [x] Feedback processing
- [x] Session generation
- [x] Unit tests

### Phase 3 - Storage ✅
- [x] JSON file persistence
- [x] Sessions and items storage
- [x] Unit tests

### Phase 4 - Minimal UI ✅
- [x] App entry point
- [x] TabView structure
- [x] TodayView
- [x] PracticeSessionView

### Phase 5 - UI Components ✅
- [x] PracticeTimerView
- [x] FeedbackBar
- [x] MetronomeBar
- [x] SongChoiceSheet
- [x] Timer architecture fix

### Phase 6 - History & SRE Feedback ✅
- [x] HistoryViewModel with tests
- [x] HistoryView with stats
- [x] SessionDetailView
- [x] SRE feedback on completion
- [x] Persist SRE items

### Post-MVP ✅
- [x] MetronomeService (AVAudioEngine)
- [x] SettingsViewModel
- [x] SettingsView

---

## In Progress

### MVP Polish (Priority 1) ✅

These items complete the current feature set:

- [x] **Wire default BPM from settings**
  - MetronomeService initializes with SettingsViewModel's defaultBPM
  - Applied when starting practice session

- [x] **Auto-start metronome by block kind**
  - Check `block.kind.defaultMetronomeOn`
  - Auto-starts for warmup and technique blocks
  - Auto-stops between blocks

- [x] **Haptic feedback**
  - HapticService with UIKit feedback generators
  - Haptics on feedback selection (Easy/Good/Hard)
  - Success haptic on session completion
  - Respects hapticFeedbackEnabled setting

---

## Planned

### Medium Priority

Features that add significant practice value:

- [ ] **Reference Module**
  - `PracticeReference` model (id, title, assetName, externalURL)
  - `PracticeReferenceView` with images
  - Link references to practice items via `referenceID`
  - Show reference button during practice blocks
  - Optional external lesson links

- [ ] **Better onboarding**
  - First-run explanation of the 4-block system
  - How feedback affects scheduling
  - Quick setup wizard

- [ ] **Session summary improvements**
  - Show feedback distribution chart
  - Suggest next focus areas based on Hard ratings
  - Streak tracking

---

## Future

### Lower Priority

Nice-to-have features for later:

- [ ] **watchOS companion**
  - Minimal timer display
  - Pause/skip/extend controls
  - Haptic feedback for block completion
  - Share state via WatchConnectivity

- [ ] **Widgets**
  - Today's practice summary
  - Current streak
  - Next due item

- [ ] **Data export**
  - Export history as JSON
  - Export as CSV for spreadsheets
  - Backup/restore functionality

- [ ] **Custom practice items**
  - Add/edit songs
  - Add/edit techniques
  - Custom scales and exercises
  - Import from library

---

## Technical Debt

Items to improve code quality:

- [ ] **Configure test target in Xcode scheme**
  - Enable running tests via `xcodebuild test`
  - CI/CD integration

- [ ] **UI tests for critical flows**
  - Start session → complete → save to history
  - Feedback affects next session
  - Settings persistence

- [ ] **Code cleanup**
  - Remove unused variables (MetronomeService warning)
  - Consistent error handling
  - Documentation comments on public APIs

---

## Notes

- Follow TDD for complex logic (engines, algorithms)
- Keep views small and presentational
- Test manually for UI/audio features
- Commit frequently with clear messages
