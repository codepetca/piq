# piq — Research-Backed Guitar Learning Guidance (Skill Catalog + SRS + Flow)

This file updates piq’s conceptual model to use a **research-backed guitar-learning architecture**, based on:

- motor learning science  
- contextual interference  
- spaced repetition (facts + skills)  
- micro-skill practice  
- interleaving  
- short guided sessions  

It describes **what** piq should do at a high level and **how** to shape the codebase, so that a coding agent (e.g. Claude) can implement details while staying aligned with:

- `design.md` — UI / UX / flows  
- `claude.md` — architecture & modules  
- `agents.md` — multi-agent roles  
- `tests.md` — testing philosophy & TDD flow  

This file is intentionally **conceptual + structural**. It does *not* prescribe every function signature; it gives Claude the “north star” for guitar learning inside piq.

---

## 1. Philosophy: piq as a Practice Coach, Not a Lesson App

piq is **not** a curriculum, course, or lesson library.

piq **is**:

- a **practice coach** that:
  - chooses *what* to practice today  
  - structures practice into **short, focused blocks**  
  - rotates skills to maximize learning (interleaving)  
  - uses **feedback** (Easy / Good / Hard) to schedule future practice  
- an app that respects:
  - minimal UI and copy  
  - no walls of text  
  - no in-app “theory lessons”  

The learning model is:

> Short, varied, spaced micro-sessions over time  
> + feedback-driven scheduling  
> + tiny visual references.

All domain and implementation details should support this.

---

## 2. Learning Model Overview (What We’re Building Toward)

### 2.1 Micro-Sessions

- Each **PracticeBlock** is a *micro-session*: ~2–5 minutes, not 20+.  
- A daily session is 3–6 micro-sessions, grouped into ~4 blocks for now.  
- Micro-sessions focus on *one* atomic skill at a time.

### 2.2 Interleaving

- Skills are **interleaved**, not blocked:
  - technique → fretboard → repertoire → rhythm  
- The SRS / scheduling logic should **avoid repeating the same category** back-to-back if possible.

### 2.3 Spaced Repetition (Skill-SRS)

- piq uses **Spaced Repetition** for both factual and procedural skills, but:
  - **factual** skills (note names, theory) will come later or via simple references.  
  - **procedural** skills (licks, chord changes, riffs, patterns) are the focus.

The engine should:

- model each skill as an item with “stability”  
- schedule reviews when skill “freshness” decays  
- use Easy/Good/Hard feedback to adapt spacing

### 2.4 Minimal Guidance, Maximum Playing

- Keep screens as in `design.md`: short labels, no subtitles.  
- Use diagrams/“?” references as quick visual cues, not tutorials.  
- Practice should feel like *play with structure*, not homework.

---

## 3. Domain Concept Additions (High-Level)

These should live in `PracticeDomain` alongside existing models (`PracticeBlock`, `PracticeSession`, `PracticeBlockKind`, `PracticeBlockFeedback`).

### 3.1 PracticeItem (Atomic Skill)

**Concept:** A single, atomic, repeatable skill that can be scheduled and tracked.

Examples:

- “Alt picking – inside string crossing”  
- “A minor pentatonic – position 1”  
- “Blues lick – 6-note run in Am”  
- “G→C open chord change”  
- “16th-note strumming pattern – 1e+a”

**Suggested shape (conceptual, not strict):**

- `id`: stable UUID  
- `title`: short display name  
- `category`: see below  
- `referenceID`: optional diagram/asset id from `design.md`  
- `stability`: 1–5 integer (1 = new, 5 = very stable)  
- `lastPlayed`: Date?  
- `nextDue`: Date?

`PracticeItem` does **not** know about timers or UI. It is a record used by the SRS.

### 3.2 PracticeItemCategory

Categories group skills into meaningful types and help map them into blocks:

- `technique` — picking, legato, bends, vibrato, etc.  
- `fretboard` — scale shapes, note mapping, patterns.  
- `rhythm` — strumming patterns, groove drills.  
- `repertoire` — licks, riffs, short musical phrases.  
- `song` — specific song sections (e.g., “Wonderwall – verse”).  
- `soloing` — improvisation prompts, motif drills, etc.

A simple `enum` in the domain is enough here.

### 3.3 Relationship to PracticeBlock

`PracticeBlock` already exists and represents **one block in today’s session**.

High-level mapping:

- Each `PracticeBlock` is linked to **one** `PracticeItem` (optionally) via `practiceItemID`.  
- The block also holds `feedback` (Easy/Good/Hard), which is fed back into the SRS for that item.  
- `referenceID` on the block can be populated from the item’s `referenceID`.

This keeps `PracticeBlock` as “today’s schedule” and `PracticeItem` as “long-term skill record”.

---

## 4. Skill Catalog (Conceptual)

piq should ship with a **small, opinionated Skill Catalog** that is:

- focused on **beginner+ to intermediate** players  
- biased toward A minor pentatonic, basic open chords, core rock/pop/blues skills  
- easily extended later  

We don’t need to encode the entire catalog in this file. Instead, define:

- There should be **15–30 seed `PracticeItem`s** at first launch.  
- They should cover:

  - Technique:
    - alternate picking (inside + outside string crossings)  
    - basic legato  
    - basic bends  
    - basic vibrato  

  - Fretboard:
    - A minor pentatonic positions 1–5 (`scale_am_pentatonic_pos1` … `pos5`)  

  - Rhythm:
    - simple 8th-note strumming pattern  
    - basic 16th-note feel  
    - simple shuffle feel  

  - Repertoire:
    - a few short blues/rock licks  
    - a simple riff or turnaround  

  - Song:
    - 2–3 example song sections (e.g. “Wonderwall verse”, “12-bar blues in E”)

The concrete items, IDs, and diagrams should be implemented in the codebase and asset catalog, but **this file’s role** is to say:

> piq should always have a curated, finite catalog of atomic skills, not an open-ended, unstructured list.

Claude should treat the catalog as data, not logic.

---

## 5. Spaced Repetition Engine (High-Level Behavior)

### 5.1 Purpose

The Spaced Repetition Engine (SRE) has a single responsibility:

> Decide which skills (`PracticeItem`s) are **due today**, and how feedback affects their future schedule.

It does **not**:

- manage timers  
- handle UI state  
- know about SwiftUI  
- replace `PracticeEngine`  

### 5.2 Inputs & Outputs

**Inputs:**

- List of all known `PracticeItem`s + their SRS fields (`stability`, `lastPlayed`, `nextDue`).  
- Feedback from blocks: `PracticeBlockFeedback` + associated `practiceItemID`.  
- The current date/time.

**Outputs:**

- A small list of recommended `PracticeItem`s to use when building today’s `PracticeSession`.  
- Updated `stability`, `lastPlayed`, `nextDue` for items after feedback is recorded.

### 5.3 Simple SRS Heuristic for MVP

For an MVP, we want a **simple, explainable** rule:

- Use **continuous stability values** starting at 1.0 (not discrete integers).
- Compute `nextDue` based on feedback:

  - **Hard**:
    - Decrease stability (e.g., multiply by 0.6, min 1.0).
    - Schedule soon: `nextDue` ~ `max(1 day, stability * 0.8 days)`.

  - **Good**:
    - Increase stability moderately (e.g., multiply by 1.15, min 1.2).
    - Schedule moderately: `nextDue` ~ `max(1.5 days, stability * 1.0 days)`.

  - **Easy**:
    - Increase stability significantly (e.g., multiply by 1.5 + add 0.5).
    - Schedule far: `nextDue` ~ `max(2 days, stability * 1.25 days)`.

The exact multipliers can be tuned in code; the important part for this file is:

> Easy → further spacing + higher stability, Hard → closer spacing + lower stability, Good → medium spacing + moderate stability growth.

The continuous model allows for more granular adaptation than discrete 1-5 levels.

### 5.4 Selecting Today’s Items

The SRE should:

1. Filter for items where `nextDue` is `<= now` (or `nil` if never played).  
2. Sort by:
   - earliest `nextDue`  
   - then lowest `stability` (hardest / newest first)  
3. Pick a small set for today (e.g., 4–8 items).  
4. Map them into blocks using categories (see below).

If there are fewer items than desired, it may:

- reuse items (with some spread if possible), or  
- temporarily pull not-yet-due items with the lowest stability.

---

## 6. Mapping Items → Blocks (Interleaving)

`PracticeEngine` is still responsible for the **session flow** and the `PracticeSession` object. The SRE helps it decide *which items* to include.

### 6.1 Category → BlockKind

High-level mapping:

- `technique`  → usually `techniqueOrTheory` block.  
- `fretboard`  → usually `warmup` block.  
- `rhythm`     → `warmup` or `song` block.  
- `repertoire` → `solo` or `song` block (short licks / riffs).  
- `song`       → `song` block.  
- `soloing`    → `solo` block.

The exact mapping function can live in the domain (e.g., a helper that, given a set of items, yields 4 `PracticeBlock`s of different kinds).

### 6.2 Interleaving Rule

When generating today’s blocks, try to:

- avoid two blocks in a row with the same category.  
- ensure at least 2 different categories per session, ideally 3–4.

Example (for 4 blocks):

1. Warm-Up (fretboard or rhythm)  
2. Technique  
3. Song  
4. Solo

If limited items make perfect interleaving impossible, keep the rule **best-effort**, not strict.

### 6.3 Micro-Block Duration

Even if the UI currently assumes ~10 minutes, `PracticeBlock.targetMinutes` can be:

- **2–5 minutes** per block as the default, especially for technique or focus-heavy drills.  
- In the future, this can be user-configurable.

The exact value is not critical in this file. The principle is:

> Short, focused blocks beat long, fatiguing ones.

---

## 7. Session Flow (Tying It All Together)

The user-facing flow stays as in `design.md`:

1. **Today** screen: shows today’s blocks (generated via SRE + PracticeEngine).
2. **Start session**: moves into a sequence of screens for each block.
3. **Block screen**: timer, metronome bar, minimal controls.
4. **Feedback screen** after each block: Easy / Good / Hard.
5. **Summary**: show how the session went.

Under the hood:

1. At app launch or when Today screen appears:
   - The app asks the SRE for **today’s items**.
   - The app maps items into 4 `PracticeBlock`s (interleaved categories).
   - `PracticeEngine` owns the `PracticeSession` built from those blocks.

2. During the session:
   - `PracticeEngine` manages timing/state.
   - Views show the timer, metronome, etc. (as in `design.md`).

3. After each block:
   - User chooses `Easy` / `Good` / `Hard`.  
   - That feedback is attached to the `PracticeBlock`.  
   - Later, a domain method can be called to feed this back into the SRE:
     - find the associated `PracticeItem`  
     - update `stability` / `lastPlayed` / `nextDue`.

4. At the end of the session:
   - Session is saved to history (Phase 3).  
   - SRE state is persisted with updated item data.

---

## 8. Persistence & Tests (Conceptual Guidance)

### 8.1 Persistence

`PracticeStorage` (or equivalent) should be responsible for:

- saving and loading:
  - past `PracticeSession`s (history)  
  - the `PracticeItem` catalog + SRS fields (stability, due dates)  
  - basic user preferences (level, styles, etc.)

Recommended approach (conceptual):

- Store:
  - a static “seed” Skill Catalog (built-in, read-only)  
  - a separate mutable SRS state (per-item stability / due dates)

The idea:

> The catalog is data describing **what** skills exist.  
> The SRS state is data describing **how well the user currently knows** those skills.

This separation allows catalog changes without breaking user state too badly.

### 8.2 Testing (High-Level)

Key areas to test, aligned with `tests.md`:

1. **PracticeEngine** (already heavily covered): state machine & timing.  
2. **SpacedRepetitionEngine**:
   - new items appear more often  
   - Easy / Hard feedback shifts due dates appropriately  
   - `generateTodaySession()` / “get items due” behavior is stable  
   - no crashes when few items exist  

3. **PracticeStorage**:
   - first-run behavior for empty SRS & history  
   - round-trip saving of sessions and SRS state

The details of the tests (file names, exact specs) belong in the test suite itself, not in this doc. This doc simply flags **what must stay true conceptually**.

---

## 9. How Claude Should Use This File

When an AI assistant (Claude, Copilot, etc.) works on piq and sees this file, it should:

1. **Not** change the fundamental UX flows defined in `design.md`.  
2. Respect architecture and module boundaries in `claude.md`.  
3. Treat this file as the **conceptual spec** for:
   - Skill Catalog  
   - SRS behavior  
   - item→block mapping  
   - micro-session philosophy  
4. Implement details inside:
   - `PracticeDomain` (models, SRE logic)  
   - `PracticeStorage` (persistence)  
   - optionally, seeding code / catalog data files  

5. Avoid:
   - adding long instructional text or tutorials  
   - turning piq into a full “lesson library”  
   - binding SRS logic directly into SwiftUI views

When in doubt:

> Keep UI minimal, keep logic in engines, keep skills atomic, and keep practice short, varied, and spaced.

---

## 10. Summary of Non-Negotiables

For future development, these are the **non-negotiable principles** this file is defending:

1. **piq is a practice coach, not a lesson platform.**  
2. **Skills are atomic (`PracticeItem`s), scheduled by SRS, and mapped into blocks.**  
3. **Practice is short, frequent, and interleaved.**  
4. **SRS is based on Easy/Good/Hard feedback and stability-based spacing.**  
5. **Engines own logic; SwiftUI views stay thin and minimal.**  
6. **The Skill Catalog is curated and finite, especially for the MVP.**  
7. **History and SRS state are persisted separately from the static catalog.**

As long as those are respected, Claude is free to design reasonable APIs, data shapes, and implementations inside the architecture already defined for piq.
