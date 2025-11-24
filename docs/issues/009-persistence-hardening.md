# Issue 009: Persistence Hardening + Model Versioning

## 1. Purpose
Strengthen the persistence layer around sessions and SRS state, and introduce simple versioning so the app can evolve without breaking user data.

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
- Add a simple versioning mechanism to stored data:
  - e.g., a top-level `schemaVersion` or equivalent.
- Implement basic migration behavior for:
  - `PracticeItem` SRS state (in case fields change).
  - `PracticeSession` history (in case models adjust).
- Improve error handling:
  - If data is corrupted or an unknown schema version appears:
    - Fail gracefully and reset or ignore offending entries.
- Maintain backwards compatibility (as much as practical for current alpha state):
  - Existing test data or early user data should not crash the app.

## 4. Implementation Notes (Optional)
- Avoid complex migration frameworks; this is a small app.
- Consider:
  - Having a `StorageState` wrapper struct with `version`, `items`, `sessions`, etc.
- Make sure this versioning strategy is documented in code comments for future issues.

## 5. Testing Requirements
- Add tests to cover:
  - Loading data with current version.
  - Loading data with an older version, if you simulate one.
  - Handling obviously malformed data.
- Ensure all existing storage tests pass and adjust if necessary to include version fields.

## 6. Deliverables
- Updated `PracticeStorage` (or equivalent) with basic versioning + error handling.
- Updated tests for storage.
- No UI changes.

## 7. Do NOT
- Do NOT significantly change domain models just for this issue.
- Do NOT add new user-facing screens or settings.
- Do NOT implement complex migration logic beyond the app’s needs.
