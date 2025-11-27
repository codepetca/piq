# GitHub Issue Workflow with Subagent Automation

When the user says "work on issue N" or you invoke `/issue N`:

## Phase 1: Planning (Auto-spawn Planner Subagent)

1. **Spawn a planner subagent** to explore the codebase and create an implementation plan
   - Provide context: issue details + `/docs/ai-instructions.md` rules
   - Task: READ-ONLY exploration (Glob, Grep, Read tools) to understand existing patterns
   - Output: Detailed implementation plan (5-10 bullets) with critical files list

2. **Fetch the issue details:**
   ```bash
   gh issue view N --json number,title,body,labels
   ```

## Phase 2: Confirmation

3. Present the plan from the subagent to the user in 5-10 bullets
4. Ask ONE clarifying question if there are ambiguities
5. Wait for user confirmation before proceeding

## Phase 3: Implementation

6. Create branch: `issue/N-<slug>` (if needed)
7. Implement following all rules from `/docs/ai-instructions.md`:
   - Architecture rules from `claude.md`
   - UI patterns from `design.md`
   - Module boundaries from `agents.md`
   - TDD approach from `tests.md`
8. Write/update tests (engines first, then integration)
9. Run tests: `swift test`

## Phase 4: Review (Auto-spawn Reviewer Subagent)

10. **Spawn a reviewer subagent** to verify:
    - Architectural compliance (no UIKit, no Combine, no timers in Views)
    - Module boundaries respected
    - Test coverage for new engine logic
    - Code quality and patterns

## Phase 5: Commit & PR

11. Show `git diff` to the user
12. Suggest commit message following repository style
13. Provide PR description template with "Closes #N"
14. Ask user if git commands should be executed

## Rules

- Do not modify unrelated files
- Do not change architecture unless required by the issue
- Keep Views thin, logic in engines
- Follow module boundaries from `agents.md`
- Add tests for new engine logic before merging

---

See `/docs/workflow/handle-issue.md` for the detailed workflow that applies to all AI platforms.
