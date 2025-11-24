# Issue 003: Daily Session Generation from SRE

## 1. Purpose
Generate each day's `PracticeSession` from the Spaced Repetition Engine (SRE) and Skill Catalog, instead of using static or hard-coded blocks. This is the heart of piq's daily guidance.

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
- Implement a domain-level function that, given:
  - the current list of `PracticeItem`s and their SRS state,
  - the current date,
  - configuration (e.g. 4 blocks per session),
  returns a `PracticeSession` for "today".
- Use the SRE to:
  - Select "due" `PracticeItem`s.
  - Sort them by due date and stability, as described in the guidance:
    - earliest `nextDue` → lowest `stability`.
- Map selected items into exactly 4 `PracticeBlock`s (for now) with:
  - `PracticeBlockKind` chosen by category (technique → technique, fretboard → warmup, etc.).
  - At least 2–3 different categories in the session where possible.
  - No strict requirement, but best-effort to avoid repeating the same category twice in a row (interleaving).
- Keep block durations short (2–5 minutes by default, consistent with guidance), but do not change UI labels yet.
- Provide a clear API surface, e.g.:
  - `PracticeSessionGenerator.generateTodaySession(items:now:) -> PracticeSession`
  - Or integrate into SRE in a way that keeps responsibilities clear and testable.

## 4. Implementation Notes (Optional)
- Generation should be deterministic in tests:
  - Use a fixed "now" when testing.
- If there are fewer than 4 due items:
  - Reuse items in a sensible way (e.g., lowest stability ones).
- If there are more than 4 due items:
  - Pick the top 4 based on due date + stability.
- Consider keeping session generation logic separate from SRE core scheduling to keep responsibilities simple.

## 5. Testing Requirements
Add or update tests to ensure:

- `generateTodaySession()` returns 4 blocks for normal catalog sizes.
- Items with earliest `nextDue` and lowest stability are picked first.
- At least two different categories appear when the catalog allows it.
- No crashes when:
  - There are fewer than 4 total items.
  - No items are strictly due (e.g., all `nextDue > now`) — in this case, use lowest stability items.
- Blocks correctly map categories → `PracticeBlockKind`.
- Block `practiceItemID` and `referenceID` are correctly set from `PracticeItem`.

## 6. Deliverables
- New domain-level session generation logic.
- New unit tests covering item selection, mapping, and edge cases.
- No modifications to SwiftUI views beyond what is strictly necessary to consume the new session API (if any).
- Minimal documentation updates only if needed (e.g. in tests or comments).

## 7. Do NOT
- Do NOT alter the block feedback UX.
- Do NOT change timers or `PracticeEngine` state machine.
- Do NOT modify `design.md`.
- Do NOT implement storage concerns in this issue (handled in Issue 004).
