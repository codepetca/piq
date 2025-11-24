# piq Roadmap (Evergreen, High-Level)

This roadmap provides long-term direction for the **piq** iOS guitar practice app.  
It aligns with the core documentation in `/docs/core/` and the conceptual model in `/docs/guidance/`.

piq is a **practice coach**, not a lesson app.  
It focuses on:
- short, interleaved micro-sessions,
- SRS-driven scheduling,
- atomic skills,
- minimal UX,
- modular architecture.

This roadmap avoids implementation details—those belong in `/docs/issues/`.

---

# 1. MVP (Core Experience)

## 1.1 Skill Catalog (Atomic Skills)
- Seed catalog (15–30 atomic skills)
- Categories: technique, fretboard, rhythm, repertoire, song, soloing
- Reference diagrams (minimal)

## 1.2 Spaced Repetition Engine (SRE) v1
- Stability-based scheduling (1–5)
- Easy/Good/Hard feedback → adaptive spacing
- “Due today” item selection
- Interleaving across categories

## 1.3 Daily Session Generation
- SRE → 4 PracticeBlocks → PracticeEngine
- Each block is 2–5 minutes
- Category diversity enforced

## 1.4 Storage Integration
- Persist PracticeItems + SRS state
- Persist session history
- Clean domain-storage boundaries

## 1.5 Stable UI Flow
- Today → Start → Block sequence → Feedback → Summary
- Minimal text, clean visuals
- Reference button (“?”)

MVP complete when user can:
- open app,
- start a session,
- practice interleaved micro-skills,
- give feedback,
- get new sessions daily,
- with persistence.

---

# 2. Post-MVP (Phase 2+)

## 2.1 Enhanced History
- Calendar view or session list
- Trends (stability growth, streaks, categories practiced)
- Simple statistics (no scores or gamification)

## 2.2 Custom Skill System
- Users create custom PracticeItems
- Optional reference diagrams or short text
- Integrates with SRE

## 2.3 Improved Summary Screen
- Clear feedback on:
  - skills practiced,
  - stability changes,
  - next due dates,
  - streaks
- Still minimal, no teaching content

## 2.4 Better Reference Material
- Slightly richer diagrams
- Optional short hints (one sentence max)
- No tutorials or lessons

## 2.5 Settings / Preferences
- Adjust micro-session duration
- Toggle metronome
- Manage skill difficulty preferences

---

# 3. Future Directions (Exploratory)

These are ideas, not commitments.

## 3.1 watchOS Companion
- Quick practice blocks
- Morning micro-sessions
- Lightweight SRS reminders

## 3.2 Widgets
- Today’s due skills
- Quick-start session widget

## 3.3 Import/Export
- Backup SRS state
- Share custom skills

## 3.4 Audio & Haptics Enhancements
- Better timing feedback
- Optional tone/haptic metronome

---

# 4. Workflow Alignment

The roadmap defines direction.  
Actual implementation happens via:

- `/docs/issues/issue-xxx.md` (tasks)
- `/docs/guidance/` (conceptual rules)
- `/docs/core/` (architecture, UI, agents, testing)

Every change must respect:
- design.md (minimal UI)
- claude.md (module boundaries)
- agents.md (roles)
- tests.md (TDD)
- piq-guitar-guidance.md (learning model)

---

# 5. Evolution

This roadmap should evolve slowly.  
Only major conceptual changes should update it.

Day-to-day tasks belong in `/docs/issues/`.

