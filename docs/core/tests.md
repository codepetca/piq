# tests.md — Test Plan for piq (TDD-Friendly & Low-Drift)

This file describes how we approach testing for piq and which areas to cover.
It is meant to **guide** test creation, not to be a perfect mirror of the code.

The goal is to:
- Focus testing where it matters most (engines & storage).
- Support a TDD-ish workflow.
- Avoid confusion as the app evolves.

---

## 1. Principles to Avoid Doc–Code Drift

To keep this file useful instead of confusing:

1. **Code + Tests are the Source of Truth for Behavior**
   - If there is a conflict between tests.md and the actual tests/code,
     the **tests/code win**.
   - When updating features, prefer updating tests and implementation first,
     then adjust this file if needed.

2. **Keep This File High-Level**
   - This file describes *what kinds of things to test*, not every single case.
   - Avoid super-specific test names or exact function signatures.

3. **Update Only When Behavior Changes Meaningfully**
   - If you tweak implementation details but behavior is the same, this file may not need changes.
   - Update this file when we:
     - Add a new module.
     - Add a new feature that changes user-visible behavior.
     - Change our testing priorities.

4. **Section-Based Ownership**
   - PracticeDomain tests → Logic/Test agents keep Section 3 in sync.
   - Storage tests → Data/Test agents keep Section 4 in sync.
   - UI tests → UI/Test agents keep Section 5 in sync.

---

## 2. Overall Testing Strategy

We use a **TDD-leaning approach** for the core logic and a pragmatic
approach for UI.

Priority order:

1. **Engines (PracticeEngine, SpacedRepetitionEngine)**  
2. **Storage (PracticeStorage)**  
3. **Integration & Smoke tests (min. UI flows)**  
4. **Optional UI snapshot tests**

### Why this order?

- Engines and storage contain the **non-trivial logic** (timing, scheduling).
- SwiftUI Views should be thin and mostly wire up data → components.
- By keeping logic out of Views, we get high confidence from engine tests alone.

---

## 3. PracticeDomain Test Plan

### 3.1 PracticeSession & Models

**Goal:** Ensure basic domain types behave as expected.

Examples of behaviors to test:

- A `PracticeSession` created for "today" has:
  - 4 blocks in the expected order (Warm-Up, Song, Solo, Technique).
- `totalMinutes` is computed correctly from block minutes.
- `PracticeBlockFeedback` values roundtrip correctly (e.g., save/load, mapping).

Tests live in something like `PracticeSessionTests.swift`.

---

### 3.2 PracticeEngine

**Goal:** Verify the session state machine and timing logic.

These tests should be written in a TDD style where practical.

Test categories:

1. **State Transitions**
   - `startSession()` moves from `.idle` → `.inBlock(index: 0, remainingSeconds: N)`.
   - Finishing a block moves to `.betweenBlocks` and then next `.inBlock`.
   - After the last block, state becomes `.finished`.

2. **Block Controls**
   - `skipCurrentBlock()`:
     - Skips to next block.
     - Marks the block as skipped or with zero `actualMinutes` if desired.
   - `extendCurrentBlock(byExtraSeconds:)`:
     - Increases remaining seconds by the amount specified.
   - `recordFeedback(forBlockAt:feedback:)` stores `Easy/Good/Hard`.

3. **Timing Behavior**
   - Given a simulated tick (e.g., calling an internal `tick()` in tests),
     remainingSeconds counts down to zero.
   - When remainingSeconds reaches zero, engine transitions out of `inBlock`.

Implementation detail:
- In tests, prefer calling a synchronous tick helper instead of real timers.

Tests live in `PracticeEngineTests.swift`.

---

## 4. SpacedRepetitionEngine Test Plan

**Goal:** Ensure items are scheduled sensibly based on feedback.

Start with a very simple model and evolve via TDD.

Test categories:

1. **Initial Scheduling**
   - New items (e.g., new scales/techniques) appear frequently at first.
   - `generateTodaySession()` returns 4 reasonable blocks.

2. **Feedback Effect**
   - Given an item recently marked **Easy**:
     - It appears less often / is scheduled further out.
   - Given an item marked **Hard** repeatedly:
     - It appears more often / sooner.

3. **Stability**
   - `generateTodaySession()` doesn’t return duplicates unless allowed by design.
   - No crashes when there are fewer items than blocks (reuse allowed).

Tests live in `SpacedRepetitionEngineTests.swift`.

This engine can start as a stubbed, heuristic implementation and become more
sophisticated over time, as long as tests are updated alongside changes.

---

## 5. Storage Test Plan (PracticeStorage)

**Goal:** Confirm sessions and preferences can be safely saved and loaded.

Test categories:

1. **First-Run Behavior**
   - When no data is present:
     - Loading sessions returns empty list.
     - Loading preferences returns sensible defaults.

2. **Round-Trip Persistence**
   - Save a session, then load sessions:
     - Check that the last saved session appears with the same ID/date/blocks.
   - Save preferences (level, styles, cues), then load and compare.

3. **Error Handling (Light)**
   - Corrupted or malformed data is handled gracefully (e.g., skip that entry).

Tests live in `PracticeStorageTests.swift`.

Implementation can use JSON in the app container or `UserDefaults` initially.

---

## 6. UI Test Plan (Thin Layer)

**Goal:** Ensure basic flows work end-to-end without exhaustively testing layout.

UI tests are **smoke tests**, not spec tests.

### 6.1 Today → Session Flow

- Start app → Today tab is visible by default.
- Today tab shows 4 blocks (kinds visible somewhere).
- Tapping `[Start session]` presents the practice screen.

### 6.2 Block → Feedback → Next Block

- From practice screen:
  - Block timer appears with title and MM:SS.
  - Tapping `Finish` (or letting it expire in a fast test build) shows feedback.
  - Tapping `[Good]` and then `[Next block]` proceeds to next block.

### 6.3 End of Session

- After the last block’s feedback:
  - A Session summary appears with all 4 blocks and feedback summary.
  - `[Close]` returns to Today or History as designed.

Tests can live in `piqUITests` as a small suite, e.g. `PiqUITests.swift`.

---

## 7. TDD Development Flow (MVP)

This section mirrors the recommended implementation flow from `claude.md`,
but focused on tests.

### Phase 0 — Models (Optional Light Tests)

- Define `PracticeBlockKind`, `PracticeBlock`, `PracticeSession`, `PracticeBlockFeedback`.
- Add tests for:
  - Correct default sessions.
  - Basic helpers (e.g., `totalMinutes`).

### Phase 1 — PracticeEngine (TDD Focus)

- Write tests for state transitions & timing behavior.  
- Implement `PracticeEngine` just enough to pass tests.

### Phase 2 — SpacedRepetitionEngine (Stub → Tested)

- Start with small tests around `generateTodaySession()` behavior.  
- Implement simple, heuristic SRE until tests pass.  
- Expand tests as behavior evolves.

### Phase 3 — PracticeStorage

- Write tests for first-run and round-trip persistence.  
- Implement minimal storage.

### Phase 4 — Minimal UI Flow

- Implement `PiqApp`, `RootView`, `TodayView`, `PracticeSessionView` using the engines.  
- Write 1–2 UI smoke tests to verify:
  - Today shows 4 blocks.
  - You can start and complete a session.

### Phase 5 — Component Extraction

- Extract `PracticeTimerView`, `MetronomeBar`, `FeedbackBar`, etc.  
- No heavy tests needed; ensure engines' tests still pass and UI smoke tests still pass.

### Phase 6 — Iterate on SRE + History

- Add more tests for SRE as it gets smarter.  
- Add tests for `HistoryViewModel` (sorting, filtering).  
- Keep the UI tests light.

---

## 8. Maintenance Guidelines for This File

- When adding a **new engine** or major behavior:
  - Add a short section here describing what to test (high level).
- When renaming or moving modules:
  - Update section headings, not every detail.
- Do not treat this file as a strict checklist; treat it as a **map** for where
  tests should live and what they generally cover.

If in doubt, favor updating **tests and code** before updating this document.
This file should help future you (and future AIs) remember the high-level plan,
not constrain implementation when reality has moved on.
