# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## 🚀 AI Agents: START HERE

**MANDATORY:** Before any work, read `.ai/START-HERE.md` and follow the 8-step initialization ritual.

This ensures:
- ✅ Environment is verified and ready
- ✅ Context is recovered from previous sessions
- ✅ Architectural boundaries are clear
- ✅ Feature status is known
- ✅ Session continuity is maintained

**Quick links:**
- `.ai/START-HERE.md` — Initialization ritual (MUST READ FIRST)
- `docs/issue-worker.md` — 9-step implementation workflow
- `docs/issue-author.md` — How to create well-formed issues

---

## Project Overview

**piq** is a minimal, distraction-free iOS guitar practice app that helps guitarists build skills through spaced repetition and deliberate practice. It tells users what to practice today in 4 guided blocks (Warm-Up, Song, Solo, Technique) with timers, simple feedback (Easy/Good/Hard), and light reference diagrams.

**Platform:** iOS 17+ (iPhone-first), SwiftUI only
**Language:** Swift (Package Manager + Xcode project)

---

## Essential Commands

### Building and Testing

```bash
# Build with Swift Package Manager
swift build

# Run all tests
swift test

# Build in Xcode (Cmd+B in Xcode GUI)
# Note: Xcode project is at ios/Piq.xcodeproj
```

### Running Individual Tests

```bash
# Run specific test target
swift test --filter piqTests

# Run specific test class
swift test --filter PracticeEngineTests

# Run specific test method
swift test --filter PracticeEngineTests.testStartSession
```

### Xcode Project Management

**CRITICAL:** When adding new Swift files to `ios/Modules/`:
1. Create the `.swift` file in the appropriate module folder
2. Add to `Package.swift` in the relevant target's `sources:` array
3. **MUST ALSO** add to `ios/Piq.xcodeproj/project.pbxproj` (Xcode builds will fail otherwise with "Cannot find 'X' in scope" errors)

---

## Required Reading Before Any Changes

**FIRST:** Follow the initialization ritual in `.ai/START-HERE.md` (mandatory for all sessions).

Then read these documentation files **as needed** based on your task:

1. `.ai/START-HERE.md` — **MANDATORY** initialization ritual and workflow
2. `/docs/core/architecture.md` — Architecture, modules, platform constraints, patterns
3. `/docs/core/design.md` — UI/UX flows, visual design system, component patterns
4. `/docs/core/agents.md` — Multi-agent collaboration patterns, responsibilities
5. `/docs/core/tests.md` — Testing philosophy, TDD approach, priorities
6. `/docs/guidance/guidance.md` — Guitar learning domain model, SRS concepts
7. Active issue file (if working on specific task): `/docs/issues/issue-*.md`

**Document hierarchy** (for conflict resolution): `.ai/features.json` > `architecture.md` > `CLAUDE.md` > `START-HERE.md` > `JOURNAL.md`

---

## Architecture Snapshot

### Core Loop

```
Today → Start session → Block (timer) → Feedback (Easy/Good/Hard) → Next → ... → Summary
```

### State Machine

`PracticeEngine.state` drives all UI:
- `.idle` → `.inBlock(index, remainingSeconds)` → `.betweenBlocks(lastIndex, nextIndex)` → `.finished`

### Module Structure (`ios/Modules/`)

- **PracticeDomain**: Models (PracticeBlock, PracticeSession), engines (PracticeEngine, SpacedRepetitionEngine, TempoEngine), persistence (PracticeStorage)
- **SessionUI**: Screens (TodayView, PracticeSessionView), components (PracticeTimerView, MetronomeBar, FeedbackBar, SessionSummaryView)
- **AudioHapticsModule**: MetronomeService, HapticService (timing & haptics only)
- **HistoryModule / SettingsModule / ReferenceModule**: Thin ViewModels + views; no business logic

**Rule:** Logic never lives in SwiftUI Views. Views compose engines/services via Observation.

---

## Strict Platform Constraints

### ✅ ALLOWED
- **SwiftUI only** (NavigationStack, TabView, .sheet/.fullScreenCover)
- **Observation** for state (@Observable + .environment)
- **Swift Concurrency** (async/await, Task{}, @MainActor)

### ❌ PROHIBITED
- **NO UIKit** (prohibited except AVFoundation in MetronomeService)
- **NO Combine** (prohibited)
- **NO NavigationView, @Published, ObservableObject** (except bridging old APIs)
- **NO timers in Views** (timers only in PracticeEngine and MetronomeService)
- **NO business logic in Views** (Views observe state only)

---

## Key Implementation Rules

### Timers
- All block countdown logic lives in `PracticeEngine`
- Metronome timing lives in `MetronomeService`
- Views **never** create or manage Timer instances
- Views observe engine state (`state`, `remainingSeconds`)

### Module Boundaries
- Follow module separation strictly (see `agents.md`)
- PracticeEngine drives session state
- SpacedRepetitionEngine handles scheduling (separate from session flow)
- Views are thin and composable
- Extract small components, no giant views

### Design Principles
- Minimal, calm, distraction-free aesthetic
- SF Symbols for all icons
- System fonts (rounded design where appropriate)
- 12pt corner radius, generous padding (16-24pt)
- Fewest words possible in UI

---

## Naming Conventions

### Reference IDs (match asset names)
- Scale: `scale_<key>_<type>_pos<n>` (e.g., `scale_am_pentatonic_pos3`)
- Chord: `chord_<root>_<quality>_<shape>` (e.g., `chord_g_major_open`)
- Technique: `tech_<category>_<slug>` (e.g., `tech_bends_basic`)
- Songs: `song_<slug>_<section>` (e.g., `song_oasis_wonderwall_verse`)

All lowercase, underscore-separated.

---

## Testing Strategy

### Priorities (TDD for engines)
1. **PracticeEngine** — State transitions, timing, block controls
2. **SpacedRepetitionEngine** — Scheduling behavior based on feedback
3. **PracticeStorage** — Save/load sessions and preferences
4. **Light UI tests** — Basic smoke tests only

### Focus
- Write tests for engine logic **before or alongside** implementation
- Keep engines pure and deterministic
- Avoid heavy UI tests; keep Views thin
- Test files in `ios/Tests/PracticeDomainTests/`

---

## Common Workflows

### Working on a GitHub Issue

**Use the standardized workflow in `docs/issue-worker.md`** (9-step process).

Quick summary:
1. Initialize with `.ai/START-HERE.md` ritual (verify env, review journal, check features)
2. Fetch issue: `gh issue view N --json number,title,body,labels`
3. Clarify ambiguities before coding
4. Create branch and Draft PR
5. Propose plan and wait for approval
6. Implement following TDD and architecture rules
7. **If adding new Swift files:** Update both Package.swift AND ios/Piq.xcodeproj/project.pbxproj
8. Update `.ai/features.json` if features completed
9. Write journal entry in `.ai/JOURNAL.md`
10. Finalize PR and validate against acceptance criteria

**See `docs/issue-worker.md` for detailed workflow.**

### Pre-Commit Checks

- ✅ No `import UIKit` (except MetronomeService for AVFoundation)
- ✅ No `import Combine`
- ✅ No `@Published` properties (use `@Observable`)
- ✅ No `Timer` in View structs
- ✅ No business logic in Views
- ✅ Module boundaries respected
- ✅ Tests exist for new engine logic

---

## PracticeEngine API

Core session management methods:
- `startSession(from: sre)` — Start session from SpacedRepetitionEngine
- `startSession()` — Start demo session
- `finishCurrentBlock()` — Complete current block
- `recordFeedback(forBlockAt:feedback:)` — Record Easy/Good/Hard
- `startNextBlock()` — Advance to next block
- `pause()` / `resume()` — Pause/resume timer
- `skipCurrentBlock()` — Skip current block
- `extendCurrentBlock(byExtraSeconds:)` — Add time to current block

---

## Important Context

### Documentation Structure
- `/docs/core/` — Stable reference (design, architecture, agents, tests)
- `/docs/guidance/` — Domain/feature guidance (guitar learning, SRS)
- `/docs/issues/` — Iteration-level tasks

### Git Workflow
- Main branch: `main`
- Follow existing commit message style
- Include `Closes #N` in PR descriptions

---

## When in Doubt

- Read the detailed docs (architecture.md, design.md, agents.md, tests.md)
- Surface ambiguities explicitly instead of guessing
- Propose minimal diffs with clear rationale
- Reference specific docs to ground discussions
- Ask ONE focused question to clarify before implementing
