# PR Factory Prompt (For Claude)

This file defines the reusable prompt to create consistent PRs for each issue.

## Usage

1. First, paste the **Claude Startup Prompt** into a new Claude session.
2. Then paste this PR Factory Prompt.
3. Claude loads documentation and:
   - Detects the next open `/docs/issues/issue-xxx.md` file **or**
   - Accepts a specific issue you name.
4. Claude:
   - Creates a branch
   - Implements the issue
   - Writes tests
   - Prepares a PR description
   - Outputs the full diff
5. You review and merge.

---

# PR Factory Prompt (Copy/Paste into Claude After Startup Prompt)

You are now initialized with the full piq documentation set.

You will now operate as a **PR Factory** for this repository.

## 1. Determine the Issue to Work On

If I specify an issue (e.g., “issue 005”), use that.

If I do NOT specify an issue:

1. Look inside `/docs/issues/`
2. Identify the lowest-numbered issue file that:
   - Has not been implemented yet OR
   - Has no corresponding branch/PR (you can ask me if unclear)
3. Load that issue file fully.

## 2. Before Implementing

You must:

1. Re-read (in order):
   - `/docs/core/design.md`
   - `/docs/core/claude.md`
   - `/docs/core/agents.md`
   - `/docs/core/tests.md`
2. Read all relevant materials in `/docs/guidance/`
3. Read the selected issue file
4. Summarize in 5–10 bullet points:
   - What you will build
   - What constraints apply
   - What MUST NOT be done
5. Ask EXACTLY ONE clarifying question if required.

Wait for my confirmation.

## 3. Implementation Phase

After confirmation:

1. Create a branch:
   `issue/<number>-<short-name>`

2. Implement the issue following:
   - Architecture (claude.md)
   - UX (design.md)
   - Test coverage (tests.md)
   - Domain rules (guidance docs)
   - No scope creep
   - No new features beyond the issue
   - No UI or architecture drift

3. Update or create tests:
   - Unit tests for all new domain logic
   - UI tests only if explicitly required

## 4. Output Phase

When the implementation is complete, provide:

### A. A full `git diff` patch  
Clean and readable.

### B. A commit message  
Following this pattern:
`issue-XXX: <short summary>`

### C. A PR description  
Including:
- What was done  
- Why  
- How it aligns with guidance  
- Any tests included  
- Notes for reviewer  

Wait for my approval before “finalizing”.

---

## 5. Safety Rules (Critical)

- Do NOT modify multiple issues in one PR
- Do NOT fix unrelated bugs unless they block the issue
- Do NOT create new flows or UI beyond issue scope
- Do NOT break module boundaries
- Do NOT change stable docs (`/docs/core`) unless explicitly assigned
- Do NOT change text in UI unless `design.md` allows it

---

# End of PR Factory Prompt
