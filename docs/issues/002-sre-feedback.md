# Issue 002: Integrate SRE Feedback into PracticeItem State

## 1. Purpose
Wire block-level feedback (Easy/Good/Hard) into the Spaced Repetition Engine (SRE) so that each `PracticeItem`'s stability and scheduling fields are updated after a session. This makes SRS actually adaptive instead of static.

## 2. Relevant Documentation
Before working on this issue, the AI must read:

1. `/docs/core/design.md`
2. `/docs/core/claude.md`
3. `/docs/core/agents.md`
4. `/docs/core/tests.md`
5. `/docs/guidance/piq-guitar-guidance.md`
6. `/docs/core/roadmap.md`
7. This issue file.

## 3. Requirements
- Introduce a clear, domain-level API for feeding back session results into the SRE.
- For each completed `PracticeBlock` that is linked to a `PracticeItem`:
  - Map `PracticeBlockFeedback` (Easy/Good/Hard) into SRS actions.
  - Update `PracticeItem.stability`, `PracticeItem.lastPlayed`, and `PracticeItem.nextDue` using the heuristic defined in `piq-guitar-guidance.md`.
- Ensure the feedback integration:
  - Lives in the domain layer (e.g., SRE or a coordinating service), not in SwiftUI Views.
  - Can be driven by tests without UI involvement.
- The heuristic to implement (high level, can be tuned in code):
  - Hard → decrease stability (min 1), schedule soon (e.g. ~1 day).
  - Good → keep stability, schedule medium (e.g. `stability * 2` days).
  - Easy → increase stability (max 5), schedule far (e.g. `stability * 4` days).
- Ensure that all date computations are deterministic/testable (e.g. inject a "now" clock where needed or isolate date math).
- Add a simple domain-level entry point such as:
  - `SpacedRepetitionEngine.applyFeedback(for blocks: [PracticeBlock])`
  - or similar, keeping it pure and platform-agnostic.

## 4. Implementation Notes (Optional)
- This issue assumes that SRE v1 and `PracticeItem` models exist (Issue 001).
- Feedback mapping should be implemented in the SRE or a closely-related domain service, *not* in `PracticeEngine` and *never* in SwiftUI.
- It should be possible to call this logic from:
  - a future History pipeline,
  - or end-of-session flow in the app layer.
- Consider how to handle:
  - Blocks with no associated `practiceItemID` (skip them).
  - Missing items (log or ignore gracefully; do not crash).

## 5. Testing Requirements
Create or extend tests to cover:

- Given a `PracticeItem` at stability 2:
  - When feedback is Hard, stability decreases or stays low and `nextDue` is soon.
- Given a `PracticeItem` at stability 3:
  - When feedback is Good, stability remains 3 and `nextDue` is in a medium range.
- Given a `PracticeItem` at stability 4:
  - When feedback is Easy, stability increases toward 5 and `nextDue` moves further out.
- Applying feedback to multiple blocks:
  - All relevant items are updated correctly.
- Handling missing/invalid mappings:
  - No crashes when a `PracticeBlock` has no `practiceItemID` or when an ID cannot be found.

## 6. Deliverables
- Updated SRE or domain service implementing feedback integration.
- New/updated unit tests for feedback → item state transitions.
- No UI changes.
- No storage changes (storage integration is handled in a later issue).

## 7. Do NOT
- Do NOT update SwiftUI views directly in this issue.
- Do NOT modify `PracticeEngine` behavior.
- Do NOT change UX flows or text.
- Do NOT introduce new block types or UI screens.
