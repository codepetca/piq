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
- Seed catalog (~30–60 atomic practice items implemented)
- Categories: warmup, fretboard, technique, theory, rhythm, chords, soloing, repertoire, songwork, ear_training, musicality (11 categories)
- Reference diagrams (minimal)
- See Section 1.7 for catalog structure details

## 1.2 Spaced Repetition Engine (SRE) v1
- Stability-based scheduling (continuous values, starting at 1.0)
- Easy/Good/Hard feedback → adaptive spacing
- "Due today" item selection
- Interleaving across categories

## 1.3 Daily Session Generation
- SRE → 6-8 PracticeBlocks → PracticeEngine
- Each block is 2–15 minutes (configurable by category)
- Session structure: warmup (first) + interleaved middle blocks + fun activity (last)
- Target session duration: ~35 minutes (acceptable range: 25-45 min)
- Category diversity enforced via interleaving algorithm

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
- practice interleaved micro-skills across all categories (technique, fretboard, rhythm, repertoire, song, soloing, ear training, musicality),
- give feedback,
- get new sessions daily,
- with persistence.

## 1.7 Practice Block Catalog

The app includes a predefined catalog of 38 practice items across 11 categories:

**Catalog Structure:**
- **Warmup** (2 items): Chromatic patterns, finger exercises
- **Fretboard** (2 items): Note naming, octave shapes
- **Technique** (4 items): Alternate picking, legato, bends, vibrato
- **Theory** (2 items): Scale degrees, triad inversions
- **Rhythm** (2 items): Strumming patterns, syncopation
- **Chords** (6 items): Barre transitions, open switches, individual chord practice
- **Soloing** (7 items): Am/Em pentatonic positions, blues licks
- **Repertoire** (3 items): Song riffs and sections (Wonderwall, Nothing Else Matters, Hotel California)
- **Songwork** (2 items): Full song practice (Blackbird, Stand By Me)
- **Ear Training** (4 items): Major/minor key feel, hum and match root, straight vs swing, interval feel
- **Musicality** (4 items): Dynamic control, controlled vibrato, bend accuracy, tone and touch

**Storage & Persistence:**
- Catalog items have stable `catalogID` strings for merging user SRS state with catalog updates
- User progress (stability, nextDue) persists separately from catalog definitions
- New items can be added to catalog without breaking user state

**Extensibility:**
- All items defined in `PracticeItemCatalog.swift`
- Each item has optional `referenceID` linking to visual diagram assets
- Custom items (user-created) planned for Phase 2+

**File:** `/ios/Modules/PracticeDomain/PracticeItemCatalog.swift`

---

# 2. Post-MVP (Phase 2+)

## 2.1 Enhanced History
- Calendar view or session list
- Trends (stability growth, streaks, categories practiced)
- Simple statistics (no scores or gamification)

## 2.2 Custom Skill System
- Users create custom PracticeItems (extension of existing catalog)
- Optional reference diagrams or short text
- Integrates with SRE using same stability/scheduling logic
- Custom items stored alongside catalog items with distinct catalogIDs
- Custom items can be created in any category, including ear training and musicality

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
- References for ear training and musicality remain minimal (tiny cues, not theory lessons)

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

