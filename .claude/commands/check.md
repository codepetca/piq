# Architecture Compliance Check

Run this command to verify that your changes follow piq's architectural rules before committing.

## Quick Checks

### Platform Rules (Strictly Enforced)
- [ ] No `import UIKit` (except in MetronomeService for AVFoundation if absolutely needed)
- [ ] No `import Combine`
- [ ] No `@Published` properties (use `@Observable` instead)
- [ ] No `ObservableObject` conformances (except when bridging old Apple APIs)
- [ ] No `Timer` instances created in View structs
- [ ] No business logic implemented in Views (Views observe state only)

### Architecture Rules
- [ ] Module boundaries respected (see `agents.md`)
- [ ] Logic lives in engines (PracticeEngine, SpacedRepetitionEngine)
- [ ] Views are thin and composable
- [ ] State management uses `@Observable` classes
- [ ] Timers only in PracticeEngine and MetronomeService

### Design Rules
- [ ] SF Symbols used for icons (no custom icon assets unless essential)
- [ ] System fonts with rounded design
- [ ] .accent (blue) for primary actions
- [ ] 12pt corner radius used consistently
- [ ] Naming conventions followed for `referenceID` patterns

### Testing Requirements
- [ ] Tests exist for new engine logic (PracticeEngine, SpacedRepetitionEngine)
- [ ] Tests exist for new storage logic (PracticeStorage)
- [ ] Tests run successfully: `swift test`
- [ ] No heavy UI tests added (keep UI tests light, smoke tests only)

## Detailed Compliance Check

For a thorough review, spawn a reviewer subagent or manually verify against:

1. **`/docs/core/claude.md`** - Architecture, modules, platform constraints
2. **`/docs/core/design.md`** - UI/UX patterns, visual design system
3. **`/docs/core/agents.md`** - Module boundaries and responsibilities
4. **`/docs/core/tests.md`** - Testing priorities and TDD approach

## If Issues Found

- Fix violations before committing
- Update documentation if architectural changes are intentional and approved
- Ask for clarification if rules conflict with requirements

---

**Remember**: Following these rules keeps piq maintainable, testable, and consistent with its minimal, calm design philosophy.
