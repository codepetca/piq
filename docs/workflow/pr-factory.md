# PR Factory Prompt (GitHub Issues as Source of Truth)

This file defines the reusable prompt you give to Claude **after** the Startup Prompt, when you want it to take a GitHub Issue and turn it into a focused PR.

In this workflow:

- **GitHub Issues are the only source of truth for work items.**
- The repo’s `/docs` folder holds only:
  - core rules (`/docs/core`),
  - conceptual guidance (`/docs/guidance`),
  - and optional workflow helpers like this file.
- There are **no longer per-issue files in `/docs/issues`**.

---

## How to Use This

1. Start a new Claude session in your IDE / environment.
2. Paste the **Claude Startup Prompt** (initialization only).
3. After Claude confirms documentation is loaded, paste this **PR Factory Prompt**.
4. Optionally specify an issue number (e.g., “Use GitHub Issue #12”), or let Claude automatically pick the “next” issue using `gh` CLI.
5. Claude will:
   - read the GitHub Issue,
   - plan the work,
   - implement the changes,
   - write tests,
   - and output a diff + PR description.

This prompt assumes:

- The environment running Claude has access to:
  - the local git repo,
  - the `gh` (GitHub CLI) command configured with auth,
  - and can run shell commands (bash/sh).

---

# ✅ PR Factory Prompt (Copy/Paste into Claude After Startup Prompt)

You are now initialized with the full piq documentation set.

You will now operate as a **PR Factory** for this repository, using **GitHub Issues as the single source of truth for work items**.

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

## 2. Before Implementing

For the chosen GitHub Issue:

1. Read the issue body **fully**.
2. Re-read (in order) the core docs paths referenced inside the issue body (e.g., `/docs/core/design.md`, `/docs/core/claude.md`, etc.).
3. Summarize the issue in **5–10 bullet points**, covering:
   - What you will build or change.
   - Important constraints or acceptance criteria.
   - Anything listed under “Do NOT” in the issue template.
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

### D. Reference the GitHub Issue in the PR description

Use GitHub’s auto-close syntax if appropriate:

- `Fixes #<number>` or `Closes #<number>`

Do **not** actually push, open the PR, or close the issue yourself (unless I explicitly say the environment supports that and ask you to do it). Instead, provide the commands I should run, for example:

- `git checkout -b issue/012-daily-session-generation`
- `git apply <patch>`
- `git commit -m "issue-012: implement daily session generation from SRE"`
- `git push origin issue/012-daily-session-generation`

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

# End of PR Factory Prompt (GitHub Issues Mode)
