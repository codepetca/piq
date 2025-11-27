# piq Documentation Overview

This folder organizes all high-level guidance, architecture rules, feature specifications, and iteration workflows for the **piq** iOS guitar practice app.

The docs follow a strict 3-layer structure so that AI assistants can work consistently without drifting from architecture, design, or practice-domain concepts.

---

# 1. Folder Structure
/docs
/core
architecture.md
design.md
agents.md
tests.md
roadmap.md

/guidance
guidance.md
# Future: additional guidance files (e.g., scheduling, watchOS)

/issues
issue-template.md
# Future: issue-001-.md, issue-002-.md, etc.

---

# 2. Layer Purposes

## **`/docs/core/` — Stable, Long-Lived Reference Docs**
These define PIQ’s unchanging rules:

- **design.md** — UI/UX flows & visual rules  [oai_citation:5‡design.md](file-service://file-WbHhgc7refSDCwWbeHPJnu)  
- **architecture.md** — architecture, platform constraints, module boundaries  
- **agents.md** — multi-agent roles & responsibilities  [oai_citation:7‡agents.md](file-service://file-Hv7q4zuHU6ddxkvCH7TKum)  
- **tests.md** — TDD philosophy and testing priorities  [oai_citation:8‡tests.md](file-service://file-8eQfYHbiXyHf4c83DaLGGu)  

These should change only when the overall system changes.

---

## **`/docs/guidance/` — Domain/Feature-Level Conceptual Guidance**
These files explain **how major concepts work** and guide implementation across multiple iterations.

Current files:

- **guidance.md** — research-backed guitar learning model, SRS, skill catalog, interleaving rules  

Future additions may include:
- scheduling-guidance.md  
- watchOS-guidance.md  
- audio-haptics-guidance.md  
- onboarding-guidance.md  

These evolve more slowly than issue files.

---

## **`/docs/issues/` — Iteration-Level Task Files**
Each file in this folder represents one **development iteration**, similar to a GitHub Issue.

Each issue file includes:
- purpose  
- requirements  
- constraints  
- reading order  
- deliverables  
- testing requirements  
- forbidden changes (to prevent drift)  

The provided **`issue-template.md`** ensures consistency.

---

# 3. Reading Order for Any AI Agent

Before modifying code, any AI assistant must read these **in order**:

1. `/docs/core/design.md`
2. `/docs/core/architecture.md`
3. `/docs/core/agents.md`
4. `/docs/core/tests.md`
5. Relevant `/docs/guidance/` files (e.g., `guidance.md`)
6. The specific `/docs/issues/issue-xxx.md` referenced in the user prompt  

Only after these are read should the AI inspect or modify source code.

This prevents architectural drift and preserves the integrity of the app.

---

# 4. Workflow Summary

1. The human (me) updates:
   - conceptual docs in `/docs/guidance/`
   - concrete task specs in `/docs/issues/`
2. The AI:
   - reads core → guidance → issue files  
   - applies required changes  
   - updates tests/code accordingly  
3. Completed issues may be archived or kept as progress history.

---

# 5. Notes

- Do not add long teaching content here (piq is a practice coach, not a course).  
- Do not store assets or large media in `/docs`.  
- Keep conceptual guidance and architectural rules crisp and minimal.  
- Keep issue files focused on a single iteration or objective.  