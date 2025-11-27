# piq Product Roadmap

This roadmap defines **what** features to build and **when**.

For **why** and **how** to implement features, see `/docs/guidance/guidance.md`.
For detailed architecture and patterns, see `/docs/core/` files.

---

## Development Workflow

```
roadmap.md (phases, features)
    ↓
GitHub Issues (specific tasks per phase)
    ↓
Implementation (following architecture + guidance docs)
```

This roadmap evolves slowly—only for major product direction changes.
Day-to-day tasks and implementation details belong in GitHub Issues and `/docs/issues/`.

---

# Phase 1: MVP (Core Experience)

**Goal:** Minimal viable practice coach that schedules skills and guides daily practice.

## Features

### Skill System
- Predefined catalog of ~38 atomic practice items
- 11 categories: warmup, fretboard, technique, theory, rhythm, chords, soloing, repertoire, songwork, ear_training, musicality
- See `/docs/guidance/guidance.md` for detailed catalog structure

### Spaced Repetition Engine (SRE)
- Stability-based scheduling
- Easy/Good/Hard feedback influences future scheduling
- "Due today" item selection
- Interleaving across categories

### Daily Session Generation
- 6-8 blocks per session
- Block duration: 2-15 minutes (varies by category)
- Session structure: warmup first → interleaved middle → fun ending
- Target: ~30-40 minutes total (acceptable range: 25-45 min)

### Storage & Persistence
- Save/load PracticeItems with SRS state
- Save/load session history
- Separate catalog from user progress data

### UI Flow
- Today screen → Start session → Block-by-block practice → Feedback → Summary
- Minimal text, calm design
- Reference diagrams ("?" button) for scales/chords/techniques

**MVP Complete When:**
User can open app, practice 6-8 interleaved micro-skills with timer and feedback, get new sessions daily, and all progress persists.

---

# Phase 2: Enhanced Experience

**Goal:** Richer feedback, customization, and history features.

## Features

### Enhanced History
- Calendar view or session list
- Trends: stability growth, categories practiced, streaks
- Simple statistics (no scores or gamification)

### Custom Skill System
- Users create custom PracticeItems
- Integrates with SRE using same scheduling logic
- Optional reference diagrams or short text
- Stored alongside catalog items with distinct catalogIDs

### Improved Summary Screen
- Show skills practiced, stability changes, next due dates
- Streak tracking
- Still minimal, no teaching content

### Better Reference Material
- Richer diagrams
- Optional short hints (one sentence max)
- No tutorials or lessons

### Enhanced Settings
- Adjust block duration preferences
- Metronome preferences
- Category preferences

---

# Phase 3: Future Explorations

**Status:** Ideas, not commitments. Evaluate after Phase 2 completion.

### watchOS Companion
- Quick practice blocks on wrist
- Lightweight SRS reminders

### Widgets
- Home screen widget showing today's due skills
- Quick-start session widget

### Import/Export
- Backup SRS state
- Share custom skills between devices/users

### Audio & Haptics Enhancements
- Improved timing feedback
- Optional haptic metronome patterns

---

## Constraints (All Phases)

Every feature must respect:
- **design.md** — minimal UI, calm aesthetic
- **architecture.md** — module boundaries, platform constraints
- **agents.md** — role separation
- **tests.md** — TDD for engines
- **guidance.md** — learning model and domain concepts

