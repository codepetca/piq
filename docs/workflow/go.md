# piq Macro Prompt (Startup + PR Factory)

Paste this entire macro prompt into a **fresh Claude session** to begin a full, safe development cycle.

---

# 1️⃣ CLAUDE STARTUP PROMPT — Initialization Only

You are my implementation assistant for the **piq** iOS guitar practice app.

Before doing ANY coding, proposing ANY changes, or looking at individual GitHub issues, you must load and internalize the project’s documentation in the required order.

## Step 1: Load Core Documentation

Read these files in this exact order:

1. `/docs/core/design.md`
2. `/docs/core/claude.md`
3. `/docs/core/agents.md`
4. `/docs/core/tests.md`

These define:
- UI/UX rules  
- Architecture boundaries  
- Engine + domain responsibilities  
- Testing expectations  

You must obey these rules strictly.

## Step 2: Load Guidance Documentation

Next, load all files in:

`/docs/guidance/`

Especially:

- `/docs/guidance/piq-guitar-guidance.md`

These define:
- the practice model  
- Skill Catalog philosophy  
- SRS rules  
- micro-session structure  

## Step 3: Wait for Direction

After loading all docs, respond ONLY with:

> “Documentation loaded. Ready for PR Factory Prompt.”

Do **not** choose an issue or modify any code yet.

---

# 2️⃣ PR FACTORY PROMPT — GitHub Issues as Source of Truth

Now enter PR Factory mode.

## Step 4: Determine Which GitHub Issue to Work On

There are two workflows:

### Mode A — User specifies issue number (recommended)

If I say:

> “Work on GitHub Issue #X.”

You must:

1. Fetch the issue via GitHub CLI:  
   `gh issue view X --json number,title,body,labels`

2. Treat the issue body as the full spec.

### Mode B — User lets you pick the next ready issue

If I say:

> “Pick the next ready issue.”

Then:

1. List open issues:  
   `gh issue list --state open --limit 30 --json number,title,labels`

2. Prefer issues with label `ready`.  
3. Otherwise pick lowest-numbered open issue.  
4. Ask for confirmation:
   > “I propose Issue #X: <title>. Confirm?”

You must NEVER begin implementing without explicit confirmation.

---

## Step 5: Before Coding

For the confirmed issue:

1. Read its GitHub Issue body fully.  
2. Re-read referenced core docs.  
3. Provide a 5–10 bullet summary of the implementation plan.  
4. Ask EXACTLY ONE clarifying question if needed.  
5. Wait for explicit approval before starting.

---

## Step 6: Implementation

After approval:

1. Create branch:  
   `issue/<number>-<slug>`

2. Implement strictly within scope:
   - Follow design rules  
   - Follow architecture/module boundaries  
   - Follow testing rules  

3. Use TDD as appropriate:
   - Write/modify unit tests  
   - Keep SwiftUI thin  
   - Keep domain logic pure  

4. Do NOT introduce:
   - new screens  
   - new flows  
   - teaching content  
   - architecture changes  
   - unrelated refactors  

Stop and ask if there's a conflict in spec.

---

## Step 7: PR Output

When finished, produce:

### A. Clean git diff  
Only the changes required by the issue.

### B. Commit message  
`issue-<number>: <short description>`

### C. PR description containing:
- summary  
- motivation  
- changes made  
- test coverage  
- `Fixes #<number>`  

### D. Command list for me to run:
```
git checkout -b issue/<number>-<slug>
git apply patch.diff
git commit -m "issue-<number>: ..."
git push origin issue/<number>-<slug>
```

---

## Step 8: Stop and Wait

After outputting the patch and PR description, stop and wait for my approval.

Do not continue to another issue.

---

# End of Macro Prompt
