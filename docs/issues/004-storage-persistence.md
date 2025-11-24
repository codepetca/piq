# Issue 004: Storage Persistence for Sessions and SRS State

## 1. Purpose
Implement the persistence layer for piq so that `PracticeSession` history and SRS state for `PracticeItem`s are saved and loaded across app launches. This completes the MVP persistence story.

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
- Implement a `PracticeStorage` (or equivalent) component responsible for:
  - Saving and loading:
    - `PracticeSession` history (completed sessions).
    - SRS state for `PracticeItem`s (stability, lastPlayed, nextDue).
  - Providing a simple, engine-friendly API.
- Use a pragmatic storage approach for MVP, such as:
  - JSON files in the app container, or
  - `UserDefaults` with encoded data blobs.
- Clean separation:
  - Catalog "seed" data stays static (bundled or in code).
  - SRS state is stored separately and merged with the catalog at load time.
- Define and implement:
  - First-run behavior:
    - No sessions → empty list.
    - No SRS state → default state based on catalog (e.g., stability 1, no nextDue).
  - Round-trip persistence:
    - Save → load yields equivalent domain objects.
- Keep storage implementation out of SwiftUI and out of the SRE/PracticeEngine core logic, accessed via simple interfaces.

## 4. Implementation Notes (Optional)
- Consider versioning:
  - Add a simple schema version field to top-level storage objects for future migrations.
- Storage APIs could look like:
  - `loadPracticeItems() -> [PracticeItem]`
  - `savePracticeItems(_:)`
  - `loadSessions() -> [PracticeSession]`
  - `saveSession(_:)` (append latest)
- You can provide async APIs using Swift Concurrency, but the internal implementation should be simple and deterministic for tests.

## 5. Testing Requirements
Add tests to cover:

- First-run behavior:
  - No files or defaults present → functions return empty sessions and default items.
- Round-trip:
  - Save a list of `PracticeItem`s with non-default SRS state.
  - Load them and confirm stability / lastPlayed / nextDue all match.
  - Save a `PracticeSession`, then load sessions and confirm it appears with correct data.
- Corruption handling (lightweight):
  - If stored data is malformed, storage should fail gracefully:
    - Possibly drop that entry and continue, or reset to defaults.
- Ensure no unexpected crashes due to IO failures.

## 6. Deliverables
- Implemented `PracticeStorage` (or equivalent) with:
  - APIs for sessions and SRS state.
- Unit tests verifying:
  - First-run behavior.
  - Round-trip storage.
  - Basic error handling.
- No UI or engine changes beyond wiring storage into engines where appropriate.

## 7. Do NOT
- Do NOT change the user-facing design or flows.
- Do NOT bundle large JSON files if not needed.
- Do NOT mix storage code into SwiftUI Views or engines; keep it in its own module.
- Do NOT over-engineer migrations; keep it minimal but future-aware.
