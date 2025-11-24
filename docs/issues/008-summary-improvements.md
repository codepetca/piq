# Issue 008: Summary Screen Improvements (MVP-Plus)

## 1. Purpose
Improve the end-of-session summary screen to better reflect the research-backed learning model (skills practiced, feedback, duration), while staying minimal and aligned with `design.md`.

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
- Enhance the Session Summary screen to show:
  - “Session complete” message.
  - List of blocks with:
    - Block kind.
    - Feedback (Easy/Good/Hard).
  - Total session minutes.
- Optionally (if data is easily available):
  - Number of unique skills practiced.
- Maintain the minimal layout described in `design.md`:
  - One simple column of text.
  - No charts, streak counters, or gamified elements in this issue.
- Ensure that:
  - Summary appears at the end of a session after final feedback.
  - There is a clear way to dismiss and return to Today or History.

## 4. Implementation Notes (Optional)
- Keep Summary logic in the UI layer or a small view model.
- Do not add SRS internals here; this screen is a view over the completed `PracticeSession`.
- You may reuse the same data that History will show; long-term, History and Summary should feel consistent.

## 5. Testing Requirements
- Light tests only:
  - Verify that a completed session yields the right summary view model data.
  - Optionally a UI test that:
    - Runs through a short session,
    - Lands on Summary,
    - Displays block count and feedback.

## 6. Deliverables
- Updated Summary screen UI.
- Any small view model or helper used to drive it.
- No domain or storage changes.

## 7. Do NOT
- Do NOT add streaks or visual gamification.
- Do NOT add SRS-specific details (stability, due dates) yet.
- Do NOT change the core flow (Today → Session → Summary → exit).
