# Issue 001: Implement Skill Catalog + SRE Integration (Phase 2)

## 1. Purpose
Integrate the Skill Catalog and the Spaced Repetition Engine (SRE) into piq so that daily sessions are generated based on Skill-SRS scheduling rather than static block definitions.

## 2. Relevant Documentation
Before working on this issue, read in order:

1. `/docs/core/design.md`
2. `/docs/core/claude.md`
3. `/docs/core/agents.md`
4. `/docs/core/tests.md`
5. `/docs/guidance/piq-guitar-guidance.md`
6. This issue file

## 3. Requirements
- Add `PracticeItem` and `PracticeItemCategory` models to PracticeDomain.
- Create an initial seed Skill Catalog (15–30 items).
- Implement SRE v1 with simple stability-based spacing.
- Modify `generateTodaySession()` to use SRE instead of static blocks.
- Ensure items map to block kinds using category rules.
- Ensure interleaving rule (avoid same category twice).
- Keep session flow unchanged (design.md).

## 4. Implementation Notes
- SRE stays pure logic, no SwiftUI imports.
- PracticeEngine remains unchanged.
- Session generation now: SRE → PracticeBlocks → PracticeEngine.
- Catalog should be static data + mutable SRS state saved via PracticeStorage.

## 5. Testing Requirements
- SRE:
  - Hard → sooner; Easy → later; Good → midpoint.
  - generateTodaySession returns 4 valid blocks.
  - No crashes with too few items.
- Storage:
  - Persist stability + nextDue correctly.
  - Round-trip SRS state through PracticeStorage.

## 6. Deliverables
- New models + SRE file.
- Updated PracticeSession generation.
- Tests for SRE and storage.
- Seed catalog file.
- No UI changes.

## 7. Do NOT
- Do NOT modify UI layouts.
- Do NOT move business logic into SwiftUI views.
- Do NOT alter PracticeEngine behavior.
- Do NOT introduce tutorials or long text.
