# Issue Author Protocol

This protocol guides the creation of well-formed GitHub issues for implementation by AI or human developers.

---

## Core Principle

**An issue should be understandable without rereading the original conversation.**

Each issue must enable an implementer to:
1. Derive a branch name
2. Devise an implementation plan
3. Implement the solution
4. Validate the change

All without requiring additional context beyond the issue itself.

---

## Title Format

Use the pattern: `type: description`

### Types

- `feat:` — New feature or capability
- `fix:` — Bug fix or correction
- `refactor:` — Code restructuring without behavior change
- `docs:` — Documentation updates
- `test:` — Test additions or improvements
- `chore:` — Build, tooling, or maintenance tasks

### Examples

✅ Good:
```
feat: add pause/resume to practice timer
fix: session state not persisting after app restart
refactor: extract feedback logic to separate engine
docs: update architecture.md with tempo engine design
```

❌ Bad:
```
Practice timer issue
Bug in session
Update some files
Make it better
```

---

## Issue Body Template

```markdown
## Summary

[1-2 sentence overview of what needs to be done and why]

## Background

[Context needed to understand this issue. What is the current state?
What problem does this solve? How did we discover this need?]

## Problem

[Clear statement of the specific problem or gap. What's not working?
What's missing? Why does this matter?]

## Acceptance Criteria

- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] Specific, testable criterion 3

[Each criterion should be pass/fail. Avoid vague terms like "better" or "improved".
Use concrete, observable outcomes.]

## Scope

### In Scope
- File/component/feature that will be changed
- Behavior that will be added/modified
- Tests that will be written/updated

### Out of Scope
- Related work that should be separate issues
- Future enhancements not needed for this issue
- Components that won't be touched

## Implementation Notes

[Optional guidance for the implementer. This might include:]
- Relevant architecture.md sections
- Related feature IDs from .ai/features.json
- Architectural patterns to follow
- Files/components likely to be affected
- Known edge cases or considerations

## Testing Plan

[How should this be verified?]
- Unit tests to write/update (e.g., "swift test --filter PracticeEngineTests")
- Manual testing steps (if applicable)
- Expected behavior after implementation

## Risks and Questions

[Known unknowns, potential complications, or questions for discussion]
- Any blocking dependencies?
- Uncertain design decisions?
- Performance or compatibility concerns?

## References

[Optional links to:]
- Related issues or PRs
- Documentation (architecture.md, design.md, guidance.md)
- External resources if applicable
```

---

## Quality Checklist

Before creating the issue, verify:

- [ ] **Title is clear and follows type:description format**
- [ ] **Acceptance criteria are specific and testable** (not vague)
- [ ] **Problem statement is concrete** (reader understands what's wrong)
- [ ] **Scope is bounded** (clear what's in/out)
- [ ] **Implementation notes reference architecture** (if applicable)
- [ ] **Testing plan is actionable** (clear how to verify)
- [ ] **Unknowns are captured** (risks/questions section has real content or is omitted)

**Test:** Can another engineer (or AI) implement this issue with no extra context?
If no, tighten the problem statement and expand acceptance criteria.

---

## When to Create Issues

Create issues for:
- ✅ Bugs and regressions
- ✅ New features or capabilities
- ✅ UX problems or improvements
- ✅ Refactors with clear motivation
- ✅ Follow-up tasks from larger work
- ✅ Test coverage gaps

Don't create issues for:
- ❌ Vague ideas ("make it better")
- ❌ Work already in progress (use PR description instead)
- ❌ One-line typo fixes (just commit directly)

---

## Relating Issues to Features

When the issue implements or completes a feature tracked in `.ai/features.json`:

1. Reference the feature ID in "Implementation Notes":
   ```
   Implements feature: `core-008` (Pause/resume practice timer)
   ```

2. Note which feature fields will be updated:
   ```
   On completion, mark feature core-008 as passing and set completedDate.
   ```

This creates traceability between GitHub issues (work items) and features.json (implementation milestones).

---

## Example: Good Issue

**Title:** `feat: add pause/resume to practice timer`

```markdown
## Summary

Add pause and resume functionality to the practice block timer so users can interrupt practice sessions without losing progress.

## Background

Currently, once a practice block starts, users cannot pause the timer. If they're interrupted (phone call, doorbell, etc.), they must either let the timer run out or skip the block entirely. This creates frustration and makes the app feel inflexible.

The PracticeEngine already owns the timer logic. We need to add pause/resume state and expose it to the UI.

## Problem

Users cannot pause the practice timer once a block has started, forcing them to skip or waste time when interrupted.

## Acceptance Criteria

- [ ] PracticeEngine has `pause()` and `resume()` methods
- [ ] PracticeEngine.state includes paused state (or remainingSeconds stops decrementing)
- [ ] PracticeSessionView shows pause/resume button when block is active
- [ ] Pausing stops the timer countdown
- [ ] Resuming continues the countdown from where it stopped
- [ ] Tests verify pause/resume behavior (PracticeEngineTests)

## Scope

### In Scope
- PracticeEngine pause/resume logic
- PracticeEngine state machine update (if needed)
- PracticeSessionView UI for pause/resume button
- Tests for pause/resume behavior

### Out of Scope
- Pause during metronome playback (metronome continues for now)
- Pause history tracking (not needed)
- Resume from cold app launch (separate issue)

## Implementation Notes

See architecture.md#practice-engine-state-machine for state machine design.

Implements feature: `core-006` (Pause and resume functionality for practice timer)

Likely files:
- `ios/Modules/PracticeDomain/PracticeEngine.swift` (add pause/resume methods)
- `ios/Tests/PracticeDomainTests/PracticeEngineTests.swift` (test pause/resume)
- `ios/PracticeSessionView.swift` (add pause/resume button)

## Testing Plan

1. Write unit tests: `swift test --filter PracticeEngineTests.testPauseResume`
2. Manual test: Start practice session, tap pause, verify timer stops, tap resume, verify timer continues

## Risks and Questions

- Should metronome also pause, or keep playing? (Assume keep playing for MVP)
- Should haptics fire on pause/resume? (No for MVP)

## References

- Related to roadmap Phase 1 session polish
- Architecture: docs/core/architecture.md#practice-engine-state-machine
```

---

## Example: Bad Issue

**Title:** `Fix the timer`

```markdown
The timer doesn't work right. Users are complaining. Please fix it.
```

**Problems:**
- No clear problem statement (what's wrong with the timer?)
- No acceptance criteria (how do we know it's fixed?)
- No scope (what files? what behavior?)
- No testing plan (how to verify?)
- Impossible to implement without asking clarifying questions

---

## Summary

Good issues are:
- **Self-contained** — No need to read original chat
- **Specific** — Clear problem and acceptance criteria
- **Actionable** — Implementer knows what to do
- **Testable** — Clear verification steps
- **Bounded** — In/out scope defined

Use this protocol to create issues that can be picked up by any developer or AI agent and implemented successfully.
