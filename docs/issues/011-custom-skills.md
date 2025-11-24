# Issue 011: Custom Skills System (User-Defined PracticeItems)

## 1. Purpose
Allow users to define their own custom `PracticeItem`s (skills) that integrate with the existing SRS system, so piq can adapt to their evolving practice needs.

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
- Extend the domain to support user-created `PracticeItem`s:
  - A minimal creation flow:
    - Title (short).
    - Category (technique, fretboard, rhythm, repertoire, song, soloing).
    - Optional referenceID or short note (if allowed by `design.md`).
- Ensure:
  - Custom items are persisted alongside built-in items’ SRS state.
  - SRE treats custom items exactly like built-in ones for scheduling.
- UI:
  - Provide a simple way to add custom skills:
    - Likely via Settings or a bare-bones "Manage skills" screen.
    - Keep UI minimal, no large forms or paragraphs.
- Validation:
  - Protect against empty titles.
  - Limit length of titles to keep UI clean.

## 4. Implementation Notes (Optional)
- Internally, distinguish seed/built-in items from user-defined:
  - via a flag or `source` field, but treat them uniformly in SRE.
- Adding or deleting custom items should not break SRS state:
  - If a custom item is deleted, its state can be dropped.
- Consider using a separate storage bucket/section for custom items data.

## 5. Testing Requirements
- Domain tests:
  - Creating and storing custom `PracticeItem`s works and round-trips via storage.
- SRE tests:
  - Custom items are scheduled like any other item.
- Optional UI tests:
  - Creating a new custom skill results in it appearing in some session within a reasonable timeframe.

## 6. Deliverables
- Domain changes for custom `PracticeItem`s.
- Storage changes to persist them.
- Minimal UI flow for creating (and optionally deleting) custom skills.
- Tests for domain and storage behavior.

## 7. Do NOT
- Do NOT add large text editors or long descriptions.
- Do NOT build a full curriculum or library browser.
- Do NOT alter the minimal UX rules in `design.md`.
