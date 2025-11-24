# Issue 006: Minimal UI Polish + Component Extraction

## 1. Purpose
Refine the core practice UI to match `design.md` and extract key reusable components (`PracticeTimerView`, `MetronomeBar`, `FeedbackBar`, `SongChoiceSheet`) without changing underlying logic.

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
- Implement and/or refine the following SwiftUI components in accordance with `design.md`:
  - `PracticeTimerView`
    - Concentric rings for block + session time.
    - Central timer label and block title.
  - `MetronomeBar`
    - Icon-only metronome row with BPM and +/- controls; no “Metronome” text.
  - `FeedbackBar`
    - Three buttons: Easy / Good / Hard, minimal styling.
  - `SongChoiceSheet`
    - Simple list of up to 3 song/section options with a title and cancel.
- Ensure:
  - Components are as stateless as possible and configured via props + callbacks.
  - No business logic (timers, SRS, storage) enters these Views.
- Update the practice screen and feedback screen to:
  - Use these components.
  - Match layout and icon usage described in `design.md`.

## 4. Implementation Notes (Optional)
- Keep naming and structure consistent with modules described in `claude.md`:
  - These components likely live in `SessionUI` or an equivalent UI module.
- For the concentric rings:
  - Visual accuracy is more important than animation perfection for MVP.
- For `SongChoiceSheet`:
  - Use existing song metadata where available from domain / catalog.
  - Keep copy minimal: “Choose a song” + 3 items + Cancel.

## 5. Testing Requirements
- No heavy UI testing is required.
- Optionally:
  - Snapshot tests for components, or
  - Very light UI tests to ensure components appear and respond to taps.
- Ensure existing engine tests still pass; UI changes must not break logic.

## 6. Deliverables
- Implemented SwiftUI components: `PracticeTimerView`, `MetronomeBar`, `FeedbackBar`, `SongChoiceSheet`.
- Updated screens to use these components.
- No changes to domain engines or storage.
- No new navigation flows.

## 7. Do NOT
- Do NOT introduce new text-heavy screens.
- Do NOT add teaching content or long descriptions.
- Do NOT refactor engine logic.
- Do NOT change the TabView or main navigation structure.
