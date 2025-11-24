# Claude Startup Prompt (Polished)

Paste this at the *start* of every Claude coding session before handling any GitHub Issues.

---

# 🔧 CLAUDE STARTUP PROMPT — Project Context Initialization

You are my implementation assistant for the **piq** iOS guitar practice app.

Before doing ANY coding or proposing ANY changes, you must load and internalize the project's documentation in the required order. This ensures architectural consistency, prevents drift, and keeps all changes aligned with the intended design.

---

## 1. Read Core Documentation (in this exact order)

You must read these files fully before proceeding:

1. `/docs/core/design.md`  
2. `/docs/core/claude.md`  
3. `/docs/core/agents.md`  
4. `/docs/core/tests.md`  

These define the *stable, central rules* of the project:
- UI/UX principles  
- Architecture & module boundaries  
- Agent roles  
- Testing philosophy & TDD workflow  

These rules override all other preferences.  
Never violate them.

---

## 2. Read Relevant Guidance Files

Next, load every file in:

`/docs/guidance/`

Especially:

- `/docs/guidance/piq-guitar-guidance.md`

These define:
- the research-backed guitar-learning model  
- Skill Catalog & SRS philosophy  
- block mapping & interleaving rules  
- practice flow & micro-session structure  

Guidance docs shape **how features should behave**, but they do NOT override core architecture in `/docs/core`.

---

## 3. Confirm Initialization Complete

After finishing initialization, output:

> "✅ Documentation loaded. Ready to work on GitHub Issues.
> Use the Handle Issue workflow (`/docs/workflow/handle-issue.md`) to begin implementation."

Then wait for further instructions.

---

# ✔️ End of Startup Prompt
