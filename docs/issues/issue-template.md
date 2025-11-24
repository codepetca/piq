# Issue <NUMBER>: <SHORT TITLE>

## 1. Purpose
A 1–2 sentence summary of what this issue aims to implement or modify.

## 2. Relevant Documentation
Before working on this issue, the AI must read:

1. `/docs/core/design.md`        <!-- UX rules -->
2. `/docs/core/claude.md`        <!-- architecture, modules --> 
3. `/docs/core/agents.md`        <!-- multi-agent roles -->
4. `/docs/core/tests.md`         <!-- TDD + testing priorities -->
5. Any relevant files in `/docs/guidance/`, including:
   - `piq-guitar-guidance.md`
6. This issue file.

## 3. Requirements
Clear bullet points defining what must be implemented:

- Required behaviors  
- Hard constraints  
- Non-negotiable UX rules  
- Architectural boundaries  
- High-level model or engine changes  

## 4. Implementation Notes (Optional)
Hints or clarifications:

- Which module(s) this touches  
- Expected new files  
- What NOT to do (avoid drift)  

## 5. Testing Requirements
Summaries referencing ideas from `tests.md`:

- Engine logic to be tested  
- Storage persistence expectations  
- UI flow tests (if applicable)  
- Regression checks  

## 6. Deliverables
What the agent must output:

- Code diffs  
- Updated models / engines  
- Updated tests  
- Migration notes (if needed)  

## 7. Do NOT
To prevent drift, explicitly list forbidden actions:

- Do NOT modify unrelated modules  
- Do NOT adjust UI layout unless specified  
- Do NOT violate architecture rules in `claude.md`  
- Do NOT ignore reading-order requirements  