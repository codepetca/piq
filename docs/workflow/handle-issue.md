# Handle Issue Workflow (GitHub Issues as Source of Truth)

This prompt is used **after** loading project context (`load-context.md`) to turn a GitHub Issue into a focused PR.

**GitHub Issues are the only source of truth for work items.** There are no per-issue files in `/docs/issues`.

---

# ✅ Handle Issue Workflow

You are now initialized with the full piq documentation set.

You will use **GitHub Issues as the single source of truth for work items** to implement focused, scoped changes.

## 1. Determine Which GitHub Issue to Work On

There are two modes:

### Mode A — I Give You an Issue Number (Preferred)

If I say something like:

> “Work on GitHub Issue #12.”

then you must:

1. Use `gh` CLI to fetch the issue:
   - Example: `gh issue view 12 --json number,title,body,labels`
2. Treat the issue body as the full spec for this task.
3. Proceed to the “Before Implementing” section below.

### Mode B — You Select the “Next” Issue

If I **do not** specify an issue number and explicitly say something like:

> “Pick the next ready issue.”

then:

1. Use `gh` CLI to list open issues:
   - Example (you may adjust flags as needed):
     - `gh issue list --state open --limit 20 --json number,title,labels`
2. Prefer issues that:
   - Have a label like `ready` (if present), or
   - Otherwise, pick the lowest-numbered open issue.
3. Show me the candidate issue(s) and ask:

> “I propose to work on Issue #X: <title>. Confirm?”

4. Wait for my confirmation before proceeding.
5. Once confirmed, fetch the full issue:
   - `gh issue view <number> --json number,title,body,labels`

You must **never** start work on an issue without me confirming the issue number.

---

## 1.5. Assign the Issue

Once the issue is confirmed:

1. Assign the issue to yourself:
   ```bash
   gh issue edit <number> --add-assignee "@me"
   ```
2. This signals to other contributors that you're working on it.
3. If assignment fails (e.g., permission issues), note the error but proceed—assignment is helpful but not blocking.

---

## 2. Before Implementing

For the chosen GitHub Issue:

1. Read the issue body **fully**.
2. Review relevant sections from the core docs (`/docs/core`) and guidance docs (`/docs/guidance`) as they relate to this issue.
3. Summarize the issue in **5–10 bullet points**, covering:
   - What you will build or change.
   - Important constraints or acceptance criteria.
   - Any "Do NOT" items from the issue.
4. Ask **exactly one clarifying question**, but only if something is genuinely ambiguous.
5. Wait for my confirmation before modifying any code.

Do **not** create branches, change files, or run tests until I confirm the plan.

---

## 3. Implementation Phase

Once I confirm the plan:

1. Create a branch for the issue, using its number and a short slug, e.g.:
   - `issue/012-daily-session-generation`
   - `issue/007-history-module`
2. Implement the issue according to:
   - The GitHub Issue spec (body),
   - The core docs (`/docs/core`),
   - The guidance docs (`/docs/guidance`),
   - The constraints in both the issue and the docs.

While implementing:

- Keep changes **scoped strictly to this issue**.
- Respect module boundaries from `claude.md`.
- Keep SwiftUI views thin; move logic to engines / domain / view models.
- Use TDD as appropriate:
  - Add/modify tests in line with `tests.md`.
- Run applicable tests (or at least describe which tests should be run and why).

---

## 4. Output / PR Preparation

When implementation is complete:

### A. Provide a `git diff`-style patch

- Show a clean, focused diff of all changes.
- Changes should be limited to what the issue requires.

### B. Suggest a commit message

Use a consistent pattern:

- `issue-<number>: <short description>`  
  e.g., `issue-012: implement daily session generation from SRE`

### C. Provide a PR description

Include:

- **Summary** — what was implemented.
- **Motivation** — how it relates to the issue and the docs.
- **Changes** — key modules/files touched.
- **Testing** — what tests were added/updated and what was run.
- **Notes** — any caveats or follow-ups.

### D. Reference the GitHub Issue in the PR description (Required)

You **must** include GitHub's auto-close syntax in your PR description so the issue automatically closes when the PR is merged:

- Use `Fixes #<number>` for bug fixes
- Use `Closes #<number>` for features or enhancements

**Validation before PR creation:**
- Confirm the PR description contains `Fixes #<number>` or `Closes #<number>`
- Verify the number matches the issue you implemented
- If the PR does not fully resolve the issue (rare), explain why and omit the auto-close syntax

### E. Provide git commands

Provide the commands needed to create the branch, apply changes, and push:

```
git checkout -b issue/<number>-<slug>
git apply <patch>
git commit -m "issue-<number>: <description>"
git push origin issue/<number>-<slug>
```

Ask if I want you to execute these commands, or if I'll run them manually.

---

## 5. Safety & Scope Rules (Critical)

You must NOT:

- Work on more than one GitHub Issue in a single PR.
- Change architecture in ways not sanctioned by `claude.md`.
- Modify core docs in `/docs/core` unless the issue explicitly says so.
- Introduce new UI flows or screens not mentioned in the issue.
- Add large blocks of teaching content; piq is a practice coach, not a lesson app.
- Implement “future roadmap” items mentioned in other issues or in `roadmap.md` unless this specific issue requires them.

If, during implementation, you discover that the issue spec is incomplete or conflicts with core docs:

1. Stop coding.
2. Explain the conflict.
3. Ask me how to proceed.

---

# ✔️ End of Handle Issue Workflow
