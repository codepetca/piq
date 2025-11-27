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

2. **claude.md** — Architecture, modules, platform constraints, patterns
   `/Users/stew/Repos/vibe/piq/docs/core/claude.md`

3. **agents.md** — Multi-agent collaboration patterns, responsibilities
   `/Users/stew/Repos/vibe/piq/docs/core/agents.md`

4. **tests.md** — Testing philosophy, TDD approach, priorities
   `/Users/stew/Repos/vibe/piq/docs/core/tests.md`

5. **piq-guitar-guidance.md** — Guitar learning domain model, SRS concepts
   `/Users/stew/Repos/vibe/piq/docs/guidance/piq-guitar-guidance.md`

6. **Active issue file** (if working on a specific task)
   `/Users/stew/Repos/vibe/piq/docs/issues/issue-*.md`

---

## Architecture Snapshot

### Platform
- **Target**: iOS 17+ only (iPhone-first, future watchOS)
- **UI Framework**: SwiftUI (NavigationStack, TabView, .sheet/.fullScreenCover)
- **State Management**: Observation (@Observable + .environment)
- **Concurrency**: Swift Concurrency (async/await, Task{}, @MainActor for UI)
- **App Entry**: PiqApp (@main) → RootView → TabView (Today, History, Settings)

### Core Modules
Located in `ios/Modules/`:

- **PracticeDomain**: Models (PracticeBlock, PracticeSession, PracticeBlockFeedback), engines (PracticeEngine, SpacedRepetitionEngine), persistence (PracticeStorage)
- **SessionUI**: SwiftUI screens + small components (PracticeTimerView, MetronomeBar, FeedbackBar, SessionSummaryView)
- **AudioHapticsModule**: MetronomeService, HapticService (timing & haptics only)
- **HistoryModule**: ViewModels + views for past sessions
- **SettingsModule**: User preferences UI
- **ReferenceModule**: Skill catalog, reference diagrams
- **WatchModule**: (future) watchOS companion

### Core Loop
1. User opens app → sees **Today** tab with 4 blocks (Warm-Up, Song, Solo, Technique)
2. Taps **Start session** → enters block-by-block timed practice
3. After each block → answers **How was that? [Easy] [Good] [Hard]**
4. At the end → sees simple session summary
5. Over time, SpacedRepetitionEngine influences which items appear

### State Machine
`PracticeEngine.state` drives all UI:
- `.idle` → `.inBlock(index, remainingSeconds)` → `.betweenBlocks(lastIndex, nextIndex)` → `.finished`

---

## Key Constraints

### Platform Rules (STRICTLY ENFORCED)
- ✅ SwiftUI only (NavigationStack, TabView, .sheet/.fullScreenCover)
- ✅ Observation for state (no Combine, no @Published, no ObservableObject except bridging old APIs)
- ✅ Swift Concurrency (async/await, not Combine)
- ❌ **NO UIKit** (prohibited)
- ❌ **NO Combine** (prohibited, use Swift Concurrency instead)
- ❌ **NO timers in Views** (timers only in PracticeEngine and MetronomeService)
- ❌ **NO business logic in Views** (Views observe state only, engines own logic)

### Architecture Rules
- **Follow module boundaries** from agents.md — do not create monoliths
- **PracticeEngine drives all session state** — Views compose engines via observation
- **SpacedRepetitionEngine handles scheduling** — keeps SRE logic separate from session flow
- **Views are thin and composable** — extract small components, no giant views
- **Engines own logic/timers** — Views never create timers or contain business logic
- **Store settings in UserDefaults**, history in SwiftData (simple JSON for now)

### Design Rules
- **Minimal, calm, distraction-free** aesthetic — no clutter
- **SF Symbols for all icons** — no custom icon assets unless essential
- **System fonts** (rounded design where appropriate)
- **Color**: .accent (blue) for primary actions, system colors for everything else
- **12pt corner radius**, generous padding (16-24pt)
- **Small composable views** — PracticeTimerView, MetronomeBar, FeedbackBar, etc.

### Naming Conventions
`referenceID` patterns (must match asset names):
- Scale: `scale_<key>_<type>_pos<n>` (e.g., `scale_am_pentatonic_pos3`)
- Chord: `chord_<root>_<quality>_<shape>` (e.g., `chord_g_major_open`)
- Technique: `tech_<category>_<slug>` (e.g., `tech_bends_basic`)
- Licks/Songs: `licks_blues_box1`, `song_<slug>_<section>`

All lowercase, underscore-separated. Reuse exact asset name for lookup.

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
6. Implement following architecture rules from claude.md and agents.md
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
- ✅ Naming conventions followed (referenceID patterns, asset names)

### Implementation Patterns

**Create session:**
- Preferred: `engine.startSession(from: sre)` (with SpacedRepetitionEngine)
- Demo: `engine.startSession()` (for manual testing)

**Advance flow:**
- `finishCurrentBlock()` → `recordFeedback(forBlockAt:feedback:)` → `startNextBlock()`

**User actions:**
- Pause/resume: `pause()` / `resume()`
- Skip: `skipCurrentBlock()`
- Extend: `extendCurrentBlock(byExtraSeconds:)`

**Apply feedback to SRE:**
- After finishing session: `sre.applyFeedback(for: session.blocks)` in `onSessionFinished` callback

**Metronome:**
- Toggle: `MetronomeService.start()` / `stop()`
- BPM: `setBPM(_:)` or use +/- helpers

---

## When to Use Specialized Subagents (Claude Code CLI Only)

These patterns apply only when using Claude Code CLI. Other AI tools should follow the same logic manually.

### Planner Subagent — For Feature Exploration
**When to spawn:**
- User requests new feature with unclear scope ("add warmup customization")
- Changes will affect multiple modules
- Need to understand existing patterns before implementing

**What it does:**
- READ-ONLY codebase exploration (Glob, Grep, Read tools)
- Pattern discovery and architecture analysis
- Create implementation plan with critical files list
- Identify architectural constraints and module boundaries

### Reviewer Subagent — Before Committing
**When to spawn:**
- After significant implementation (before commit)
- User says "review" or "check if this follows architecture"
- Before creating PR

**What it does:**
- Check architectural compliance against claude.md and agents.md
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
- Coverage gap identification
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

## Testing Focus (See tests.md for Details)

### Priorities
1. **Unit tests for PracticeEngine** — state transitions, timing, feedback recording
2. **Unit tests for SpacedRepetitionEngine** — scheduling behavior, difficulty adjustments
3. **Unit tests for PracticeStorage** — save/load sessions, handle edge cases
4. **Light UI tests** — basic smoke tests only (Today renders 4 blocks, etc.)

### TDD Recommendation
- **Engines and storage**: Strongly favor TDD (write tests first or in parallel)
- **UI**: Keep views small and composable, rely on manual testing + occasional snapshots
- Focus TDD effort where logic is complex (timing, SRE)
- Keep UI flexible and avoid heavy UI test investment

### TDD Development Flow (6 Phases)
See tests.md for detailed phase-by-phase flow:
0. Domain skeleton (models + tests)
1. PracticeEngine (TDD for state machine)
2. SpacedRepetitionEngine (TDD for scheduling)
3. Storage (TDD for persistence)
4. Wire minimal UI (thin views, manual testing)
5. Add components & refine UI (stateless presentational components)
6. Iterate on SRE and history (always test-first for engine changes)

---

## Do / Avoid

### DO
- Maintain module boundaries from agents.md
- Keep engines pure and deterministic
- Update docs (design.md, claude.md) when changing flows
- Follow naming conventions (referenceID patterns)
- Keep views declarative and stateless
- Extract small composable components
- Write tests for engine logic before refactoring
- Surface ambiguities instead of guessing

### AVOID
- Adding timers in Views (only in engines)
- Mixing SRE logic into PracticeEngine (keep separate)
- Storing business logic in ViewModels (use engines)
- Large view structs (extract components)
- Ad-hoc persistence outside PracticeStorage
- Introducing UIKit or Combine
- Creating monoliths or god objects
- Changing architecture without updating docs first

---

## Extending the App

Before adding new features:

1. **Decide which module** it belongs to (see claude.md module descriptions)
2. **Update design.md and claude.md** with conceptual changes first
3. **Implement minimal changes** with tests following tests.md priorities
4. **Keep daily session size small** (warmup first, fun ending last, interleaved middle)
5. **Propose minimal diff** with clear rationale if uncertain

### Common Extensions

**Add new practice block type:**
1. Add case to `PracticeBlockKind`
2. Update mapping functions for labels/defaults
3. Update session generation in PracticeEngine
4. Update BlockListView to show new block
5. Add tests for new flow

**Add new reference diagram:**
1. Create asset using naming conventions
2. Add `PracticeReference` in PracticeReferenceService
3. Attach `referenceID` to relevant blocks/items
4. Confirm UI shows reference icon and opens sheet

**Extend SRE behavior:**
1. Modify SpacedRepetitionEngine only (keep isolated)
2. Use PracticeBlockFeedback as input
3. Do not move SRE logic into Views or PracticeEngine
4. Add tests to validate new scheduling behavior

---

## Questions or Ambiguities

If requirements are unclear or architecture decisions are needed:
- **Surface them explicitly** instead of guessing
- **Propose minimal diff** with clear rationale
- **Reference specific docs** (design.md, claude.md, agents.md) to ground the discussion
- **Ask ONE focused question** to clarify before implementing

---

**You are now ready to work on piq!**

Follow the architecture rules strictly, maintain the calm minimal aesthetic, use TDD for engines, and keep Views thin and composable. When in doubt, read the detailed docs (claude.md, design.md, agents.md, tests.md) and ask clarifying questions.
