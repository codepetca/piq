# Issue 012: Reference Diagram Improvements

## 1. Purpose
Improve the reference diagram system so that users can more easily recall shapes (scales, chords, techniques) using the `?` reference flow, while keeping UI minimal.

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
- Ensure `referenceID` handling is fully wired:
  - PracticeBlocks with `referenceID` show the `questionmark.circle` icon on the Practice screen.
  - Tapping it opens a sheet with the appropriate diagram.
- Improve the diagram library:
  - Ensure all initial catalog items have matching `referenceID` → asset mappings (at least for core scales/chords/tech drills).
- Update the reference sheet UI:
  - Show a short title (e.g., “Am pentatonic – pos 1”).
  - Show the diagram image.
  - Optional: a minimal button like “Open lesson” that can be a stub for now.
- Keep content:
  - Visual and minimal.
  - No paragraphs of text.

## 4. Implementation Notes (Optional)
- Reference assets can initially be placeholders but should match the IDs in `design.md` and `piq-guitar-guidance.md`.
- Keep all reference logic in a small service or module (e.g., `PracticeReferenceService`), not spread across views.
- Consider a simple registry/dictionary for `referenceID` → assetName/title.

## 5. Testing Requirements
- Unit tests (or light tests) for the reference service:
  - Given a `referenceID`, the correct asset + title info is returned.
- Optional UI test:
  - A PracticeBlock with a `referenceID` shows the `?` icon.
  - Tapping it presents a sheet.

## 6. Deliverables
- Completed wiring of reference system:
  - IDs, assets, and UI sheet.
- Reference service or helper.
- Minimal tests to prevent obvious regressions.

## 7. Do NOT
- Do NOT add long teaching text.
- Do NOT introduce a full reference browser or curriculum.
- Do NOT break the minimal “? sheet” design in `design.md`.
