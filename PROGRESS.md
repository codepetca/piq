# piq Development Progress

Tracking progress through the TDD development phases outlined in `claude.md`.

---

## Phase Overview

- [x] **Phase 0** - Domain skeleton (no UI yet)
- [ ] **Phase 1** - PracticeEngine (driven by tests)
- [ ] **Phase 2** - SpacedRepetitionEngine (stub then grow)
- [ ] **Phase 3** - Storage
- [ ] **Phase 4** - Wire minimal UI (thin views)
- [ ] **Phase 5** - Add components & refine UI
- [ ] **Phase 6** - Iterate on SRE and history

---

## Phase Details

### Phase 0 - Domain skeleton ✅
**Status:** Complete

- [x] Define core models: `PracticeBlockKind`, `PracticeBlock`, `PracticeSession`, `PracticeBlockFeedback`
- [x] Add simple factory helpers
- [x] Xcode project setup with iOS 17 target
- [x] Basic app structure with TabView
- [ ] Tests for model invariants (e.g. 4 blocks per session)
- [ ] Tests for derived properties (e.g. total minutes)

---

### Phase 1 - PracticeEngine
**Status:** Not started

Write tests first for state machine:
- [ ] `startSession()` puts engine into first `.inBlock`
- [ ] Tick/advance logic updates `remainingSeconds` correctly
- [ ] `finishCurrentBlock()` moves to `.betweenBlocks` then next block
- [ ] `skipCurrentBlock()` skips correctly without breaking state
- [ ] `extendCurrentBlock(by:)` adds time as expected
- [ ] Implement `PracticeEngine` to satisfy tests

---

### Phase 2 - SpacedRepetitionEngine
**Status:** Not started

- [ ] Tests for simple heuristic (new items appear more often)
- [ ] Items marked Easy appear less frequently
- [ ] Items marked Hard appear more frequently
- [ ] Implement minimal `SpacedRepetitionEngine`
- [ ] Wire `generateTodaySession()` that returns 4 blocks

---

### Phase 3 - Storage
**Status:** Not started

- [ ] Tests for `PracticeStorage` first-run behavior
- [ ] Save/load session round-trips correctly
- [ ] Implement JSON/UserDefaults-based storage

---

### Phase 4 - Wire minimal UI
**Status:** Not started

- [ ] Connect `TodayView` to show 4 blocks from engine
- [ ] Starting session moves engine to `.inBlock`
- [ ] Timer updates view via observation
- [ ] Manual simulator testing

---

### Phase 5 - Add components & refine UI
**Status:** Not started

- [ ] Extract `PracticeTimerView`
- [ ] Extract `MetronomeBar`
- [ ] Extract `FeedbackBar`
- [ ] Extract `SongChoiceSheet`
- [ ] Keep views stateless/presentational with callbacks
- [ ] Add UI tests for critical flows

---

### Phase 6 - Iterate on SRE and history
**Status:** Not started

- [ ] Tests for new SRE scheduling behavior
- [ ] Tests for `HistoryViewModel`
- [ ] Grow SRE logic as needed
