# Issue 014: Summary Screen v2 (Stability & Next Steps)

## 1. Purpose
Enhance the Session Summary screen to give very lightweight insight into SRS-related progress (e.g., which skills got stronger or need work) while keeping the UI minimal and non-gamified.

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
- Extend the existing Summary screen (Issue 008) with subtle SRS-related info, such as:
  - A short line like:
    - “3 skills reinforced, 1 needs more work”
  - Or a note such as:
    - “Next focused on: bends, pos 2 scale”
- Data should be derived from:
  - Feedback (Easy/Good/Hard) for blocks.
  - Optional: changes in `PracticeItem.stability`.
- Keep the presentation:
  - Text-only or near-text-only.
  - No charts, bars, or scores.
- Keep copy minimal and neutral; avoid “gamified” language.

## 4. Implementation Notes (Optional)
- Logic for inferring “reinforced” vs “needs work” can be:
  - Hard → needs more work.
  - Easy/Good → reinforced.
- A small helper or view model can compute these summaries using the completed `PracticeSession` and (if easily available) SRE feedback results.
- Consider future extensibility:
  - This summary could later tie into History trends.

## 5. Testing Requirements
- Unit tests for the summary logic:
  - Given a set of blocks and feedback, ensure the computed text summary matches expectations.
- Optional UI test:
  - Run a fake session and confirm the v2 summary copy appears.

## 6. Deliverables
- Updated Summary screen with subtle SRS-friendly copy.
- Helper logic + tests for generating the summary text.
- No changes to core SRE scheduling.

## 7. Do NOT
- Do NOT display numeric “scores” or grades.
- Do NOT show raw stability values or SRS internals.
- Do NOT add complex visuals or charts.
