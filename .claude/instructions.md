# Claude Code Configuration for piq

## Main Instructions

Read the universal AI instructions file for comprehensive guidance:

**`/Users/stew/Repos/vibe/piq/docs/ai-instructions.md`**

This file contains all architecture rules, workflows, and constraints that apply to ALL AI platforms (Claude, Copilot, ChatGPT, Codex, Gemini).

---

## Claude Code CLI Enhancements

As a Claude Code CLI user, you have access to additional workflow automation:

### Slash Commands Available

- **`/init`** - Load project context quickly (reads ai-instructions.md)
- **`/issue N`** - Work on GitHub issue with subagent automation
- **`/check`** - Verify architecture compliance before committing

### Automatic Subagent Spawning

Claude Code will automatically spawn specialized subagents when appropriate:

- **Planner Subagent**: Feature requests with unclear scope, multi-module changes, architecture exploration
- **Reviewer Subagent**: Before commits, architectural compliance checks, test coverage verification
- **Tester Subagent**: Test development, failure investigation, coverage gap identification

See `/docs/ai-instructions.md` for detailed subagent patterns and when to spawn them.

---

## Quick Reference

### Platform Constraints
- iOS 17+ only, SwiftUI + Observation
- NO UIKit, NO Combine, NO timers in Views
- Engines own logic, Views observe state

### Module Boundaries
PracticeDomain, SessionUI, AudioHapticsModule, HistoryModule, SettingsModule, ReferenceModule

### Core Loop
Today → Start session → Block (timer) → Feedback → Next → Summary

### State Machine
`.idle` → `.inBlock` → `.betweenBlocks` → `.finished`

---

**For complete details, always reference `/docs/ai-instructions.md` and the core documentation files it points to.**
