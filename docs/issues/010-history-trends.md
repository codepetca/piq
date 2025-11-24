# Issue 010: Enhanced History – Trends & Simple Stats

## 1. Purpose
Extend the History module to show simple trends and lightweight statistics that reflect user progress over time, without adding heavy charts or gamification.

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
- Add simple trend information to History, such as:
  - Total minutes practiced this week vs last week.
  - Number of sessions in the last N days.
- Optionally:
  - Show a small note like “Practiced 3 days this week” (still minimal text).
- Keep visuals simple:
  - No complex charts in this issue.
  - A summary text above or below the session list is enough.
- Ensure that the calculations are:
  - Done using existing session data.
  - Efficient and testable.

## 4. Implementation Notes (Optional)
- Trends may be computed in:
  - A `HistoryViewModel`, or
  - A small helper/service used by History.
- Keep logic separate from SwiftUI so tests can validate calculations.
- The numbers should be approximate and human-readable, not exact analytics.

## 5. Testing Requirements
- Tests for trend calculations:
  - Given a known set of sessions, ensure stats (e.g. total minutes per week) match expectation.
- No strict need for UI tests here, but you may add one if trivial.

## 6. Deliverables
- Updated History UI to display simple trend info.
- Supporting logic/tests for trend calculations.
- No change to how sessions are stored.

## 7. Do NOT
- Do NOT add heavy graphs or visualizations.
- Do NOT introduce social or gamified features.
- Do NOT alter core session generation logic.
