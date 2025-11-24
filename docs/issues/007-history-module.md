# Issue 007: Basic History Module Implementation

## 1. Purpose
Implement a simple History view that lists past sessions and lets the user inspect the breakdown of a single session, consistent with the minimal history design in `design.md`.

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
- Implement a History tab UI that:
  - Shows a simple list of past sessions (date + total minutes).
  - Uses data from `PracticeStorage` (Issue 004).
- Implement a session detail view that shows:
  - Session date.
  - Each block with its kind and feedback (Easy/Good/Hard).
  - Total minutes.
- Layout should closely follow the History design in `design.md`:
  - Simple vertical list.
  - No charts or heavy visuals in this issue.
- Ensure:
  - History tab is readable and minimal.
  - Tapping a list row opens the detail view.

## 4. Implementation Notes (Optional)
- Keep History logic in its own module or view model (e.g. `HistoryModule`), as per `claude.md` and `agents.md`.
- Loading sessions should be done through `PracticeStorage` only.
- Decide on a reasonable limit for sessions to show (or just show all for now).

## 5. Testing Requirements
- Add tests for any `HistoryViewModel` or equivalent:
  - Sorting sessions by most recent first.
  - Mapping from domain `PracticeSession` to UI rows.
- Optionally add UI tests:
  - History tab shows some sessions after a few test runs.
  - Tapping a session row shows a detail screen.

## 6. Deliverables
- New History tab UI (list + detail).
- View model / logic class to back the History views, with tests if appropriate.
- Integration with `PracticeStorage` to load past sessions.

## 7. Do NOT
- Do NOT add charts or advanced analytics yet.
- Do NOT add filters, search, or tags.
- Do NOT change how sessions are generated or saved (that’s previous issues).
