# piq iOS Project — AI Agent Instructions

You are working on **piq**, a minimal, distraction-free iOS guitar practice app that helps guitarists build skills through spaced repetition and deliberate practice.

---

## Quick Start

1. **Read the documentation files below in order** before making any code changes
2. **Follow the architecture constraints strictly** — no exceptions
3. **Use the workflows described** for common tasks (handling issues, checking compliance)

---

## Required Reading Order

Read these files to understand the project architecture (order matters):

1. **design.md** — UI/UX flows, visual design system, component patterns
   `/Users/stew/Repos/vibe/piq/docs/core/design.md`

2. **architecture.md** — Architecture, modules, platform constraints, patterns
   `/Users/stew/Repos/vibe/piq/docs/core/architecture.md`

3. **agents.md** — Multi-agent collaboration patterns, responsibilities
   `/Users/stew/Repos/vibe/piq/docs/core/agents.md`

4. **tests.md** — Testing philosophy, TDD approach, priorities
   `/Users/stew/Repos/vibe/piq/docs/core/tests.md`

5. **guidance.md** — Guitar learning domain model, SRS concepts
   `/Users/stew/Repos/vibe/piq/docs/guidance/guidance.md`

6. **Active issue file** (if working on a specific task)
   `/Users/stew/Repos/vibe/piq/docs/issues/issue-*.md`

## Optional Contextual Reading

**roadmap.md** — Product phases and feature timeline
   `/Users/stew/Repos/vibe/piq/docs/core/roadmap.md`

Read this when:
- Planning new features or creating issues
- User asks about feature priorities or scope
- Uncertain whether a feature belongs in MVP vs Phase 2+
- Avoiding scope creep during implementation

---

## Architecture Snapshot

**Platform:** iOS 17+ only (SwiftUI + Observation + Swift Concurrency)

**App Entry:** PiqApp → RootView → TabView (Today, History, Settings)

**Core Modules** (located in `ios/Modules/`):
- **PracticeDomain**: Models, engines (PracticeEngine, SpacedRepetitionEngine), persistence
- **SessionUI**: Screens + small components (PracticeTimerView, MetronomeBar, FeedbackBar, etc.)
- **AudioHapticsModule**: MetronomeService, HapticService
- **HistoryModule / SettingsModule / ReferenceModule**: Thin ViewModels + views

**Core Loop:**
1. User opens app → sees **Today** tab with 4 blocks (Warm-Up, Song, Solo, Technique)
2. Taps **Start session** → enters block-by-block timed practice
3. After each block → answers **How was that? [Easy] [Good] [Hard]**
4. At the end → sees simple session summary
5. Over time, SpacedRepetitionEngine influences which items appear

**State Machine:** `PracticeEngine.state` drives all UI
- `.idle` → `.inBlock(index, remainingSeconds)` → `.betweenBlocks(lastIndex, nextIndex)` → `.finished`

---

## Key Constraints (STRICTLY ENFORCED)

### Platform Rules
- ✅ SwiftUI only (NavigationStack, TabView, .sheet/.fullScreenCover)
- ✅ Observation for state (no Combine, no @Published, no ObservableObject except bridging old APIs)
- ✅ Swift Concurrency (async/await, not Combine)
- ❌ **NO UIKit** (prohibited)
- ❌ **NO Combine** (prohibited)
- ❌ **NO timers in Views** (timers only in PracticeEngine and MetronomeService)
- ❌ **NO business logic in Views** (Views observe state only, engines own logic)

### Architecture Rules
- **Follow module boundaries** from agents.md — do not create monoliths
- **PracticeEngine drives all session state** — Views compose engines via observation
- **SpacedRepetitionEngine handles scheduling** — keeps SRE logic separate from session flow
- **Views are thin and composable** — extract small components, no giant views
- **Engines own logic/timers** — Views never create timers or contain business logic

### Design Rules
- **Minimal, calm, distraction-free** aesthetic
- **SF Symbols for all icons**
- **System fonts** (rounded design where appropriate)
- **12pt corner radius**, generous padding (16-24pt)

---

## Common Workflows

### Working on a GitHub Issue

See `/docs/workflow/handle-issue.md` for detailed workflow.

**Basic steps:**
1. Fetch issue: `gh issue view N --json number,title,body,labels`
2. Understand requirements, read relevant code
3. Create implementation plan (5-10 bullets)
4. Ask ONE clarifying question if needed
5. Get user confirmation before starting
6. Implement following architecture rules from architecture.md and agents.md
7. Write/update tests (TDD for engines, see tests.md)
8. Run `swift test` to verify
9. Show `git diff`
10. Suggest commit message following repo style
11. Provide PR description with "Closes #N"

**Rules:**
- Do not modify unrelated files
- Do not change architecture unless required by issue
- Keep Views thin, logic in engines
- Follow module boundaries from agents.md
- Add tests for new engine logic before merging

### Checking Architecture Compliance

Before committing changes, verify:
- ✅ No `import UIKit` (except in MetronomeService for AVFoundation if needed)
- ✅ No `import Combine`
- ✅ No `@Published` properties (use `@Observable` instead)
- ✅ No `Timer` instances in View structs (only in PracticeEngine/MetronomeService)
- ✅ No business logic in Views (Views compose and observe engines)
- ✅ Module boundaries respected (no cross-module coupling)
- ✅ Tests exist for new engine logic (see tests.md priorities)

---

## When to Use Specialized Subagents (Claude Code CLI Only)

These patterns apply only when using Claude Code CLI. Other AI tools should follow the same logic manually.

### Planner Subagent — For Feature Exploration
**When to spawn:**
- User requests new feature with unclear scope
- Changes will affect multiple modules
- Need to understand existing patterns before implementing

**What it does:**
- READ-ONLY codebase exploration
- Pattern discovery and architecture analysis
- Create implementation plan with critical files list

### Reviewer Subagent — Before Committing
**When to spawn:**
- After significant implementation (before commit)
- User says "review" or "check if this follows architecture"
- Before creating PR

**What it does:**
- Check architectural compliance against architecture.md and agents.md
- Verify module boundaries not violated
- Ensure no prohibited patterns (UIKit, Combine, timers in Views)
- Verify test coverage for engine logic

### Tester Subagent — For Test Development
**When to spawn:**
- New engine logic needs tests
- Test failures need investigation
- Coverage gaps identified

**What it does:**
- Test development following tests.md TDD approach
- Focus on engines first (PracticeEngine, SpacedRepetitionEngine)
- Swift test execution and reporting

---

## Platform-Specific Usage Notes

### Claude Code CLI
- Reads `.claude/instructions.md` automatically (which references this file)
- Use slash commands: `/init`, `/issue N`, `/check`
- Subagents spawn automatically when appropriate (planner, reviewer, tester)

### GitHub Copilot
- Reads `.github/copilot-instructions.md` (which references this file)
- Provides inline suggestions based on architectural context
- Follow same rules as above for all suggestions

### ChatGPT / Codex / Google Gemini
- User manually uploads this file (`/docs/ai-instructions.md`)
- Follow all architecture rules and workflows described above
- Manually apply the same patterns that subagents would use

---

## Questions or Ambiguities

If requirements are unclear or architecture decisions are needed:
- **Surface them explicitly** instead of guessing
- **Propose minimal diff** with clear rationale
- **Reference specific docs** (design.md, architecture.md, agents.md) to ground the discussion
- **Ask ONE focused question** to clarify before implementing

---

**You are now ready to work on piq!**

Follow the architecture rules strictly, maintain the calm minimal aesthetic, use TDD for engines, and keep Views thin and composable. When in doubt, read the detailed docs (architecture.md, design.md, agents.md, tests.md) and ask clarifying questions.
