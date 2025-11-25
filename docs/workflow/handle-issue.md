# piq — GitHub Issue Workflow

When I say “work on issue #X”, follow this sequence:

1. Fetch the GitHub Issue:
   gh issue view X --json number,title,body,labels

2. Read the issue body + core docs (design.md, claude.md, agents.md, tests.md, piq-guitar-guidance.md).

3. Summarize the plan in 5–10 bullets.

4. Ask one clarifying question only if needed.

5. Wait for confirmation before coding.

6. After confirmation:
   - Create branch: issue/X-<slug>
   - Implement using architecture rules.
   - Add/update tests.
   - Produce git diff.
   - Suggest commit message.
   - Provide PR description with “Closes #X”.

7. Ask if git commands should be executed.

Do not modify unrelated files or design/architecture unless required by the issue.
