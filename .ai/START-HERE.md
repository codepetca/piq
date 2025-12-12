# START HERE: AI Agent Initialization Ritual

**CRITICAL:** Every AI session working on piq **MUST** begin by following this ritual. This ensures continuity, prevents architectural violations, and maintains project quality.

---

## The 8-Step Workflow

### 1. Verify Environment

Run the environment verification script:

```bash
bash scripts/verify-env.sh
```

This checks:
- Swift compiler is installed
- `swift build` succeeds
- `swift test` passes
- Xcode project exists at `ios/Piq.xcodeproj`
- `.ai/` infrastructure is present

**If this fails, STOP and fix the environment before proceeding.**

---

### 2. Review Recent Context

Recover context from previous sessions:

**a) Read the last 3-5 journal entries:**
```bash
tail -100 .ai/JOURNAL.md
```

**b) Check recent git activity:**
```bash
git log --oneline -10
```

**c) Review recent closed PRs/issues (if applicable):**
```bash
gh pr list --state merged --limit 5
gh issue list --state closed --limit 5
```

**Goal:** Understand what was done recently and identify any human-initiated changes since your last session.

---

### 3. Check Feature Status

Get current project status:

```bash
bash scripts/features-status.sh
```

This shows:
- Current development phase
- Total features (passing vs failing)
- Next failing features to work on

**Note the current phase and any blocked features.**

---

### 4. Review Architecture (When Needed)

Consult `docs/core/architecture.md` when:
- Starting work on a new component
- Uncertain about architectural patterns
- Need to understand module boundaries
- Making design decisions

**Quick reference sections:**
- Module structure and dependencies
- State management patterns (Observation)
- Timer ownership rules
- Platform constraints

---

### 5. Identify Your Task

**Priority order:**

1. **GitHub issue assigned to you** → Use `gh issue view N`
2. **Pull request needing review** → Use `gh pr view N`
3. **Next failing feature** → Check `.ai/features.json` for next `"passes": false` entry in current phase
4. **User's explicit request** → Follow their instructions

**For GitHub issues:** Read the full issue body, check acceptance criteria, note any referenced feature IDs.

---

### 6. Plan Before Coding

**Task Complexity Determines Approach:**

#### For Code Changes (STRICT):
1. State your understanding of the task in 3-5 sentences
2. Reference relevant architecture.md sections
3. Propose implementation approach (files to change, tests to add)
4. Estimate which features in `.ai/features.json` will be affected
5. **WAIT FOR USER APPROVAL** before writing any code

#### For Research/Exploration (FLEXIBLE):
1. State what you're investigating
2. Propose search/read strategy
3. Proceed without waiting (but ask questions if blocked)

**Never skip the planning step for code changes.**

---

### 7. Execute Your Work

#### Development Guidelines

**Follow TDD:**
- Write tests before or alongside implementation
- Run `swift test` frequently
- Ensure tests pass before marking features complete

**Respect Architectural Boundaries:**
- ✅ Use SwiftUI only (NavigationStack, TabView, sheets)
- ✅ Use @Observable for state management
- ✅ Use async/await for concurrency
- ❌ **NEVER import UIKit** (except AVFoundation in MetronomeService)
- ❌ **NEVER import Combine**
- ❌ **NEVER use @Published** (use @Observable instead)
- ❌ **NEVER create timers in Views** (timers only in PracticeEngine/MetronomeService)
- ❌ **NEVER put business logic in Views** (Views observe engines only)

**Module Ownership:**
- PracticeEngine → session state machine, timers, block flow
- SpacedRepetitionEngine → scheduling, feedback → next due date
- TempoEngine → BPM tracking, tempo progression
- PracticeStorage → persistence, UserDefaults
- Views → thin, composable, observe state only

**Commit Frequently:**
- Use logical, atomic commits
- Follow commit message style (see below)
- Don't batch unrelated changes

**Update Feature Status:**
When you complete a feature:
1. Edit `.ai/features.json`
2. Set `"passes": true`
3. Add `"completedDate": "2025-MM-DD"`
4. Update meta.passing and meta.failing counts
5. Commit `.ai/features.json` with your code

---

### 8. End-of-Session Journal Entry

**MANDATORY** for sessions where you:
- Wrote or modified code
- Explored architecture and made decisions
- Encountered blockers or failures
- Completed features

**Format:**

```markdown
## YYYY-MM-DD HH:MM [AI Model Name]

**Goal**: [One sentence describing the objective]
**Issue**: #N (or "None")
**Branch**: branch-name (or "main")

**Changes**:
- [File path]: [What changed]
- [File path]: [What changed]

**Commits**: [commit hash, commit hash]
**Tests**: ✅ All passing (or ❌ X failing)
**Feature Status**: [Marked feature-id as passing/failing, or "No features affected"]

**Next**: [What should happen next, or follow-up tasks]
**Blockers**: [Any issues preventing progress, or "None"]
```

**After writing journal entry:**
1. Commit `.ai/JOURNAL.md` and `.ai/features.json` together
2. Push all changes to remote

---

## Architectural Boundaries (CRITICAL)

These rules are **INVIOLABLE**. Breaking them requires explicit user approval and architectural discussion.

### Rule 1: No Platform Frameworks in Core Logic

**NEVER import UIKit in PracticeDomain modules.**

- ✅ PracticeDomain can import: Foundation only
- ❌ No: UIKit, SwiftUI, Combine, CoreMotion, WatchKit
- ⚠️ Exception: AVFoundation in MetronomeService (audio playback)

### Rule 2: No Business Logic in Views

**Views are presentation only.**

- ✅ Views observe @Observable engines/ViewModels
- ✅ Views call engine methods in response to user actions
- ❌ No timers, no calculations, no state machines in Views
- ❌ No @Published properties (use @Observable classes)

### Rule 3: Timer Ownership

**Timers live in engines, never in Views.**

- ✅ PracticeEngine owns the block countdown timer
- ✅ MetronomeService owns the metronome tick timer
- ❌ Views NEVER create Timer instances
- ❌ Views observe `remainingSeconds` or similar state

### Rule 4: Observation Framework Only

**Use @Observable, not Combine.**

- ✅ `@Observable class PracticeEngine`
- ✅ `.environment(engine)` for injection
- ✅ Direct property access in Views
- ❌ No `@Published` properties
- ❌ No `ObservableObject` protocol
- ❌ No `.sink()` or Combine pipelines

---

## Document Hierarchy (Conflict Resolution)

When sources conflict, trust this order:

1. **`.ai/features.json`** → Feature completion status (source of truth for what's done)
2. **`docs/core/architecture.md`** → System design, patterns, module boundaries
3. **`CLAUDE.md`** → Project overview, conventions, platform constraints
4. **`.ai/START-HERE.md`** (this file) → Workflow and ritual
5. **`.ai/JOURNAL.md`** → Historical context (informational only)

If architecture.md and CLAUDE.md disagree, trust architecture.md. If uncertain, ask the user.

---

## Commit Message Style

**Format:** `Component: imperative action`

**Rules:**
- Imperative mood, no period: "Add pause/resume to PracticeEngine"
- Keep subject line under 50 characters when possible
- Optional component prefix when relevant: "PracticeEngine: fix timer restart bug"
- Body is optional (only include if "why" is non-obvious)
- No issue numbers in subject line (git log should be clean; PRs link issues)

**Examples:**

✅ Good:
```
PracticeEngine: add pause/resume methods
Fix timer restart bug in session flow
Add SpacedRepetitionEngine feedback logic
Update TodayView to show microblock structure
```

❌ Bad:
```
Updated files for issue #42.
Fixed bug
WIP
asdf
Made some changes to the practice engine to add pause and resume functionality as requested in the GitHub issue
```

---

## Feature-to-Issue Relationship

**Understand the difference:**

- **`.ai/features.json`** = Implementation milestones (what's built and working)
- **GitHub Issues** = Work items (tasks, bugs, refactors, enhancements)

**Relationship:**
- Not 1:1 mapping
- One feature may span multiple issues
- One issue may affect multiple features
- Cross-reference using `relatedIssues` field in features.json
- Issues can reference feature IDs in body: "Implements feature: `core-008`"

**When to update features.json:**
- Feature implementation is complete and verified
- Tests pass for that feature's verification command
- Code represents a "done" state for that capability

**When NOT to update features.json:**
- Minor bug fix that doesn't complete a feature
- UI polish/tweaks that don't represent new functionality
- Documentation-only changes
- Refactors that don't add new capabilities

---

## Quick Reference: Common Commands

```bash
# Environment check
bash scripts/verify-env.sh

# Feature status
bash scripts/features-status.sh

# Run all tests
swift test

# Run specific test class
swift test --filter PracticeEngineTests

# Run specific test method
swift test --filter PracticeEngineTests.testPauseResume

# Build project
swift build

# View GitHub issue
gh issue view 42

# View recent commits
git log --oneline -10

# View journal tail
tail -50 .ai/JOURNAL.md
```

---

## Workflow Summary (Quick Checklist)

For **code implementation** sessions:

- [ ] Run `bash scripts/verify-env.sh`
- [ ] Review last 3-5 journal entries
- [ ] Check `bash scripts/features-status.sh`
- [ ] Identify task (issue/feature/user request)
- [ ] Propose plan and wait for approval
- [ ] Follow TDD, respect architectural boundaries
- [ ] Commit frequently with good messages
- [ ] Update `.ai/features.json` if features completed
- [ ] Write journal entry
- [ ] Commit and push all changes

For **research/exploration** sessions:

- [ ] Quick context check (journal tail + git log)
- [ ] State what you're investigating
- [ ] Read files, search codebase
- [ ] Answer user's question or provide findings
- [ ] (Optional) Write journal entry if significant discoveries made

---

## This Ritual Ensures:

✅ **Continuity** – Every AI session picks up exactly where the previous one left off
✅ **Quality** – Architectural boundaries are never violated
✅ **Progress** – Features are tracked and verified systematically
✅ **Efficiency** – No wasted tokens reconstructing context
✅ **Transparency** – User can see what was done and what's next

**Remember: This ritual is not optional. It's the foundation of effective AI collaboration on piq.**
