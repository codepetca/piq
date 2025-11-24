# Issue 005: TodayView Wiring to SRE-Driven Session

## 1. Purpose
Connect the Today screen UI to the new SRE-driven practice session so that users see and start a session generated from the Skill Catalog and SRS state.

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
- Wire `TodayView` (or equivalent root UI for the Today tab) to:
  - Request or construct today’s `PracticeSession` using the generation logic from Issues 001–003.
  - Display the 4 blocks for today, consistent with `design.md` (simple list or summary).
- Implement the “Start session” action to:
  - Instantiate or bind to `PracticeEngine` with the generated `PracticeSession`.
  - Navigate to the practice screen as defined in `design.md`.
- Ensure:
  - `PracticeEngine` remains the owner of session state (blocks, timing, etc.).
  - TodayView stays thin: it asks for a session, shows a minimal summary, and starts the engine.
- Handle lifecycle:
  - If the user returns to Today during an active session, the state should be handled sensibly:
    - Either show that there is an active session,
    - Or allow starting a new one, depending on the simplest MVP approach (document which you choose in comments).

## 4. Implementation Notes (Optional)
- Keep all business logic out of SwiftUI Views:
  - TodayView should bind to a small view model/observable using domain APIs.
- Consider whether the session is generated:
  - At app launch,
  - On Today tab appear,
  - Or lazily when “Start session” is pressed.
  Document the choice briefly in code comments.
- This issue does NOT add new styling beyond what `design.md` allows.

## 5. Testing Requirements
- Add light integration or unit tests where feasible:
  - Ensure TodayView/ViewModel requests a session from the proper domain API.
  - Ensure “Start session” leads to an engine starting in `.inBlock` state.
- Optionally add a UI test:
  - Launch app → Today shows 4 blocks.
  - Tap “Start session” → practice screen appears.

## 6. Deliverables
- Updated Today tab UI wiring to use SRE-driven sessions.
- Minimal view model changes / additions as needed.
- Optional small UI test verifying flow, plus any unit tests around the VM.
- No changes to SRE internals beyond what is necessary to expose the session.

## 7. Do NOT
- Do NOT change the overall navigation structure (TabView etc.).
- Do NOT change the appearance rules in `design.md`.
- Do NOT implement new screens.
- Do NOT introduce teaching content or longer copy on Today.
