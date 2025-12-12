# Issue Worker Protocol

This protocol outlines the step-by-step workflow for implementing GitHub issues in the piq project.

**Target audience:** AI agents and human developers picking up issues to implement.

---

## Prerequisites

Before starting any issue implementation, you **MUST** complete the initialization ritual defined in `.ai/START-HERE.md`.

Quick checklist:
- [ ] Run `bash scripts/verify-env.sh`
- [ ] Review last 3-5 journal entries
- [ ] Check `bash scripts/features-status.sh`
- [ ] Review architecture.md if working on unfamiliar components

**Do not skip this step.** It ensures you have correct context and a working environment.

---

## The 9-Step Implementation Workflow

### Step 1: Fetch & Understand

**Fetch the issue:**
```bash
gh issue view N --json number,title,body,labels
```

**Read carefully:**
- Problem statement
- Acceptance criteria (these define "done")
- Scope (what's in/out)
- Implementation notes (architectural guidance)
- Related feature IDs from `.ai/features.json`

**Summarize your understanding** in 3-5 sentences. State:
- What problem you're solving
- What changes you'll make
- What tests you'll write
- Which features (if any) this completes

---

### Step 2: Clarify Ambiguities

**Ask questions if:**
- Acceptance criteria are unclear
- Multiple valid approaches exist
- Architectural patterns are uncertain
- Scope is ambiguous

**Ask ONE focused question** before proceeding. Don't guess at requirements.

Examples:
- "Should metronome pause when timer pauses, or keep playing?"
- "Should this use SpacedRepetitionEngine or TempoEngine for scheduling?"
- "Is this feature in scope for this issue, or a follow-up?"

**Wait for answers** before moving to implementation.

---

### Step 3: Setup Branch

**Derive branch name:**

For issues: `issue/N-slug`
- Example: `issue/42-pause-resume-timer`

For features (flexible): `feature/name`
- Example: `feature/onboarding-flow`

**Check for existing branch:**
```bash
git fetch
git branch -a | grep "issue/42"
```

**Create branch if needed:**
```bash
git checkout -b issue/42-pause-resume-timer
```

Or checkout existing branch:
```bash
git checkout issue/42-pause-resume-timer
git pull origin issue/42-pause-resume-timer
```

---

### Step 4: PR Management

**Check for existing PR:**
```bash
gh pr list --head issue/42-pause-resume-timer
```

**If no PR exists, create Draft PR:**
```bash
gh pr create --draft \
  --title "feat: add pause/resume to practice timer" \
  --body "$(cat <<'EOF'
## Summary
Add pause/resume functionality to practice timer.

## Implementation Plan
1. Add pause() and resume() methods to PracticeEngine
2. Update state machine to track paused state
3. Add pause/resume button to PracticeSessionView
4. Write tests for pause/resume behavior

## Progress
- [ ] PracticeEngine pause/resume methods
- [ ] Tests for pause/resume
- [ ] UI for pause/resume button
- [ ] Manual testing

## Related
Closes #42
Implements feature: core-006
EOF
)"
```

**If PR exists, load it:**
```bash
gh pr view issue/42-pause-resume-timer
```

Keep the PR updated as you work. It's your implementation scratchpad.

---

### Step 5: Plan & Approve

**Propose detailed implementation steps:**

State your plan covering:
1. **Architecture** — Which engines/modules you'll modify
2. **Files** — Specific files you'll change
3. **Tests** — What tests you'll add/update
4. **Features** — Which `.ai/features.json` entries you'll update

**Example plan:**
```
Implementation plan for pause/resume timer:

1. Modify PracticeEngine (ios/Modules/PracticeDomain/PracticeEngine.swift):
   - Add isPaused property
   - Add pause() method (stops timer, keeps remainingSeconds)
   - Add resume() method (restarts timer from remainingSeconds)

2. Update PracticeEngineTests (ios/Tests/PracticeDomainTests/PracticeEngineTests.swift):
   - Test pause() stops countdown
   - Test resume() continues from pause point
   - Test multiple pause/resume cycles

3. Update PracticeSessionView (ios/PracticeSessionView.swift):
   - Add pause/resume button when inBlock state
   - Show "Paused" indicator when isPaused
   - Call engine.pause() / engine.resume() on tap

4. Update .ai/features.json:
   - Mark core-006 as passing
   - Set completedDate

This follows architecture.md timer ownership rules (engine owns timer).
No changes to metronome (keeps playing during pause).
```

**WAIT FOR USER APPROVAL** before coding.

**Strictness:**
- **Code changes:** MUST get approval before proceeding
- **Research/exploration:** Can proceed without approval

---

### Step 6: Execute

**Follow TDD:**
1. Write test first (or alongside implementation)
2. Implement feature to make test pass
3. Run `swift test` to verify
4. Refactor if needed

**Respect Architectural Boundaries** (see `.ai/START-HERE.md`):
- ✅ SwiftUI only (no UIKit except AVFoundation in MetronomeService)
- ✅ @Observable for state (no @Published)
- ✅ Timers in engines only (never in Views)
- ✅ Business logic in engines (Views are presentation only)

**Commit frequently:**
```bash
git add ios/Modules/PracticeDomain/PracticeEngine.swift
git commit -m "PracticeEngine: add pause/resume methods"

git add ios/Tests/PracticeDomainTests/PracticeEngineTests.swift
git commit -m "Add tests for pause/resume functionality"

git add ios/PracticeSessionView.swift
git commit -m "Add pause/resume button to session view"
```

**Use good commit messages** (see `.ai/START-HERE.md` commit style):
- Imperative mood, no period
- < 50 chars when possible
- Optional component prefix
- Body only if "why" is non-obvious

**Push commits:**
```bash
git push origin issue/42-pause-resume-timer
```

**Update `.ai/features.json` when features complete:**
If you completed a feature, edit `.ai/features.json`:
```json
{
  "id": "core-006",
  "passes": true,
  "completedDate": "2025-12-12"
}
```

Update meta counts:
```json
"passing": 21,  // increment
"failing": 7    // decrement
```

Commit features.json:
```bash
git add .ai/features.json
git commit -m "Mark core-006 as passing"
git push
```

---

### Step 7: Finalize PR

**Update PR body with progress:**
```bash
gh pr edit issue/42-pause-resume-timer --body "$(cat <<'EOF'
## Summary
Add pause/resume functionality to practice timer.

## Changes
- Added pause() and resume() methods to PracticeEngine
- Updated state machine to track isPaused state
- Added pause/resume button to PracticeSessionView
- Wrote comprehensive tests for pause/resume behavior

## Testing
✅ All tests pass: swift test
✅ Manual testing: pause/resume works correctly

## Related
Closes #42
Implements feature: core-006 ✅

## Commits
- abc123f: PracticeEngine: add pause/resume methods
- def456a: Add tests for pause/resume functionality
- ghi789b: Add pause/resume button to session view
- jkl012c: Mark core-006 as passing
EOF
)"
```

**Change from Draft to Ready for Review:**
```bash
gh pr ready
```

---

### Step 8: Validate

**Compare against acceptance criteria:**

Go back to the original issue and check each criterion:
- [ ] PracticeEngine has pause() and resume() methods ✅
- [ ] State includes paused tracking ✅
- [ ] UI shows pause/resume button ✅
- [ ] Tests verify behavior ✅

**Run full test suite:**
```bash
swift test
```

**Manual testing** (if applicable):
Follow the testing plan from the issue.

**Confirm completion:**
State clearly: "All acceptance criteria met. Ready for review."

---

### Step 9: Document

**Write journal entry** in `.ai/JOURNAL.md`:

```markdown
## 2025-12-12 16:45 [Claude Sonnet 4.5]

**Goal**: Implement pause/resume functionality for practice timer
**Issue**: #42
**Branch**: issue/42-pause-resume-timer

**Changes**:
- ios/Modules/PracticeDomain/PracticeEngine.swift (added pause/resume methods, isPaused state)
- ios/Tests/PracticeDomainTests/PracticeEngineTests.swift (added pause/resume tests)
- ios/PracticeSessionView.swift (added pause/resume button)
- .ai/features.json (marked core-006 as passing)

**Commits**: abc123f, def456a, ghi789b, jkl012c
**Tests**: ✅ All passing (swift test)
**Feature Status**: Marked core-006 as passing
**PR**: https://github.com/codepetca/piq/pull/105 (Ready for review)

**Next**: Await PR review
**Blockers**: None
```

**Commit journal:**
```bash
git add .ai/JOURNAL.md
git commit -m "Add journal entry for pause/resume implementation"
git push
```

**Session complete.**

---

## Critical Rules

### Never Skip Architectural Boundaries

❌ **DO NOT:**
- Import UIKit in PracticeDomain modules
- Use @Published or Combine
- Create timers in Views
- Put business logic in Views

✅ **DO:**
- Follow architecture.md patterns
- Use @Observable for state
- Keep timers in engines
- Make Views thin and composable

**If you need to violate a boundary, STOP and ask for approval.**

---

### Never Silently Change Architecture

If you discover that the architecture needs to change to solve the issue:
1. **STOP implementation**
2. **Document the architectural conflict**
3. **Propose the architectural change**
4. **Get user approval**
5. **Update architecture.md if approved**
6. **Then proceed**

Do not make architectural changes without explicit discussion.

---

### Never Skip Journal Entries

Journal entries are **mandatory** for code changes. They provide:
- Session continuity for future AI agents
- Historical record of what was done and why
- Commit and feature tracking
- Blocker visibility

If you wrote code, you must write a journal entry.

---

## Branch Naming Flexibility

You have flexibility in branch naming:

**For GitHub issues:**
- Preferred: `issue/N-slug` (e.g., `issue/42-pause-resume`)
- Allowed: `feature/name` if it makes more sense

**For feature work:**
- Use `feature/name` when not tied to specific issue
- Example: `feature/onboarding-improvements`

**For bug fixes:**
- Use `fix/description` or `issue/N-fix-bug`

The key is clarity, not strict convention.

---

## When Things Go Wrong

### Tests Failing

1. Read test output carefully
2. Fix the issue
3. Re-run tests
4. Don't mark features as passing if tests fail

### Blocked by Dependencies

1. Note the blocker in `.ai/features.json`:
   ```json
   "blockedBy": ["core-010"]
   ```
2. Write journal entry documenting the blocker
3. Ask user what to work on instead

### Uncertain About Approach

1. STOP implementation
2. Ask clarifying question
3. Wait for answer
4. Resume with clear direction

**Never guess at requirements or architecture.**

---

## Summary Checklist

For every issue implementation:

- [ ] Initialized with `.ai/START-HERE.md` ritual
- [ ] Fetched and understood the issue
- [ ] Asked clarifying questions if needed
- [ ] Created/checked out branch
- [ ] Created/loaded Draft PR
- [ ] Proposed plan and got approval
- [ ] Implemented following TDD and architectural rules
- [ ] Committed frequently with good messages
- [ ] Updated `.ai/features.json` if features completed
- [ ] Finalized PR and marked ready for review
- [ ] Validated against acceptance criteria
- [ ] Wrote journal entry
- [ ] Committed and pushed all changes

Follow this protocol for consistent, high-quality implementations.
