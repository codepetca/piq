# piq — Design Guide (UI / UX / Flow)

This document defines how piq looks, feels, and flows.
It is the single source of truth for all visual, UX, interaction, and naming patterns.
All code, screens, and features must follow this guide.

---

# 1. Design Philosophy

piq is a **minimal, calm, distraction‑free** guitar practice companion.

Rules:
- Use the **fewest words possible**.
- No subtitles or long text blocks.
- One main purpose per screen.
- Max **3 choices** when asking the user to choose.
- Clean whitespace and simple typography.
- No teaching curriculum; just practice guidance.

piq is a **practice app**, not a course.

---

# 2. App Theme & Visual Language

piq should feel calm, focused, and modern. The UI should disappear and let
the user focus on playing guitar.

## Color

Use system colors with a gentle, cool accent:

- Background: system background (`.systemBackground`).
- Primary accent: a cool blue/teal via `.tintColor` configured at app level.
- Secondary accent: muted gray for secondary text and borders.

Avoid:
- Very bright, saturated colors.
- Heavy outlines or harsh gradients.

## Typography

- Font: SF Pro (system).  
- Sizes:
  - Titles: 20–24 pt, medium or bold.  
  - Block labels: 14–16 pt.  
  - Small labels/body: 12–14 pt.  
  - Timer: 36–48 pt, bold, rounded.

## Corners & Layout

- Corner radius: 12–16 pt for cards and buttons.  
- Generous vertical spacing; avoid crowding.  
- One main focal element per screen (e.g., timer on practice screen).

## Icons (SF Symbols)

Use SF Symbols for consistent, minimal iconography:

- Metronome: `metronome`
- Pause/Resume: `pause.circle`, `play.circle`
- Skip: `forward.end`
- Add time: `plus.circle`
- Check/Done: `checkmark.circle`
- Close: `xmark`
- Reference info: `questionmark.circle`
- Settings: `gear`
- Today/Home: `guitars` or `house`
- History: `clock.arrow.circlepath`

Icons should be:
- Monochrome, using accent or secondary label colors.
- Paired with short labels when clarity is needed (bottom buttons, tab bar).
- Not decorative; every icon should indicate a clear action or destination.

---

# 3. Core Loop Overview

Every practice session follows this sequence:

```text
Today → Start session → Preview (10s) → Block screen → Feedback → Next block → … → Session summary
```

Session structure:
- 6–8 microblocks per session (≈25–45 min total).  
- Warm‑Up first, interleaved middle, “fun ending” block last.  
- Each microblock 2–10 minutes depending on category.  
- Feedback after every block: Easy / Good / Hard.

---

# 4. Practice Timer UI (Concentric Rings)

This is the central UI element of piq.

## Rings

- **Outer ring** = progress through the current block.
  - 10–12 pt stroke, primary accent color.
- **Inner ring** = progress through the full session.
  - 6–8 pt stroke, same color at low opacity (~50%).
- Both rings are centered horizontally and fill clockwise from 12 o'clock.

## Timer Area (inside rings)

Inside the concentric rings:

- Small label: block title (single line, truncated if needed).  
- Large label: countdown timer (MM:SS, bold).

Tap anywhere on the rings to **pause/resume** the timer.

When paused:
- Rings stop animating.
- Timer text and title slightly dimmed.
- A small `pause.circle` or `play.circle` icon may appear near the timer.

## Under Rings: Metronome Bar (icon‑based)

The metronome is represented by icons, not by the word “Metronome”.

Layout (single horizontal row):

- Left:
  - Toggle button with SF Symbol `metronome`.
  - OFF: icon in secondary color.  
  - ON: icon tinted with primary accent.
- Right:
  - BPM value text, e.g. `70`.  
  - Two icon buttons:
    - Decrease BPM: `minus.circle`.  
    - Increase BPM: `plus.circle`.

Example row:

```text
[ metronome icon ]   70   [ − ] [ + ]
```

No extra label like “Metronome” should be shown.

## Bottom Controls Row

Icon-based controls for practice flow management:

**Core controls (always visible):**
- **Skip** - Skip to next block
  - Icon: `forward.fill`
  - Position: Left
- **Pause/Resume** - Toggle timer pause state
  - Icon: `pause.fill` / `play.fill`
  - Position: Center (emphasized, larger)
- **Extend** - Add extra time to current block
  - Icon: `plus.circle`
  - Position: Right

**Contextual controls (appear when relevant):**
- **Reference** - View diagram for current block
  - Icon: `questionmark.circle`
  - Only shown when block has `referenceID`

Buttons use icon-only design (no text labels). Pause/Resume is visually emphasized as the primary control.

## Block Instructions (Optional Guidance)

Brief practice tips appear below the block title when helpful:

- **Format:** 2–4 bullet points (5–10 words each, action-oriented)
- **Focus Cue:** One encouraging sentence in accent color
- **Behavior:**
  - Collapsed by default (shows focus cue only)
  - Tap the focus cue to expand/collapse full instruction list
  - Auto-collapse when timer is paused to avoid obscuring controls
- **Constraints:**
  - Max 4 bullets to avoid wall-of-text
  - No teaching paragraphs—cues only
  - Timer remains the primary focus
  - Max height ~100pt when expanded

**Instruction Variation:**

To keep guidance fresh, instructions rotate across sessions:
- **Core instructions** (1-2 bullets): Always shown, never change
- **Bonus tip** (1 bullet): Rotates from a pool of 3-5 tips
- **Focus cue** (1 line): Rotates from a pool of 2-3 cues

Example:

```
Chromatic Warm-Up

⟩ Super slow, perfect tone

[When expanded:]
• 1–2–3–4 pattern, one finger per fret
• Use strict alternate picking
• Check every note rings clearly
```

**Session Prompt:**

On the first block only, a brief motivational prompt appears at the top:
- "Short bursts beat long grinds. Keep moving."
- Dismissible with X button
- Auto-hides after first block

---

# 5. Block Feedback Screen

Appears immediately after each block ends or the user taps Finish.

Layout:

- Centered text: **"How was that?"** (no subtitles).  
- A `FeedbackBar` component showing three buttons:
  - [Easy] [Good] [Hard]
- Each button may optionally include a small icon, but must have text:
  - Easy: optional `hand.thumbsup`.  
  - Good: text only or filled thumbs‑up.  
  - Hard: optional `flame` or `exclamationmark.circle`.
- Below FeedbackBar:
  - Primary button:
    - `[Next block]` (with `chevron.right` icon), or  
    - `[Done]` (with `checkmark.circle` icon).

No extra explanatory text is allowed.

---

# 6. Reference System ("?" Diagrams)

Some blocks support a tiny reference diagram so users can quickly recall a shape.

## Trigger

- An SF Symbol `questionmark.circle` appears beside the block title on the Practice screen if a `referenceID` is available.

## Modal Layout

When tapped, it opens a sheet:

- Title: short (e.g., "Am pentatonic – pos1").  
- Diagram image (scale, chord, technique).  
- Optional button: "Open lesson" with an external‑link icon (`arrow.up.right.square`).  
- Standard close (swipe down or `xmark` in the nav bar).

No paragraphs or long teaching text. No scrolling lesson content.

---

# 7. Song Choice Sheet

When a Song block starts and needs a specific section, a song choice sheet appears.

Layout:

```text
Choose a song

• "Wonderwall – verse"
• "Gravity – intro"
• "12‑bar blues in E"

[Cancel]
```

Rules:
- Max **3 options**.  
- Flat list; no subtitles or descriptions.  
- Tapping a song sets that block’s title and closes the sheet.

---

# 8. Onboarding Flow

On first launch, the user goes through a short, minimal onboarding:

1. **Welcome**
   - Title: "piq"
   - Subtitle: "Guitar practice"
   - Primary button: `[Get started]`

2. **Level**
   - Options (radio buttons or chips):
     - Beginner+
     - Intermediate
     - Advanced
   - Primary button: `[Next]`

3. **Styles**
   - Multi‑select chips:
     - Rock, Pop, Blues, R&B, Worship
   - Primary button: `[Next]`

4. **Cues**
   - Options:
     - Sound + Vibration  
     - Vibration only  
     - Silent  
   - Primary button: `[Done]`

5. **First Session Summary**
   - Planned: shows today’s 6–8 microblocks (Warm‑Up first, interleaved middle, fun ending).  
   - Primary button: `[Start session]`

No tutorials, no long explanations.

---

# 9. Practice Blocks

Session mix: 6–8 microblocks per day (≈25–45 min), always starting with Warm‑Up and ending with a “fun” block. Middle blocks interleave categories to avoid repeats.

The core block types:

- **Warm‑Up**  
  - Scales, patterns, mechanics.  
  - Metronome ON recommended.

- **Song**  
  - Work on a short song section (verse, riff, intro).  
  - Song chosen from up to 3 options.

- **Solo**  
  - Improvisation in a given key.  
  - Metronome OFF by default, optional ON.

- **Technique**  
  - Bends, vibrato, alternate picking, legato, etc.  
  - Metronome ON recommended for many drills.

Blocks must be simple, repeatable, and non‑verbal (no long instructions).

---

# 10. Naming Conventions (IDs & Assets)

Reference IDs and assets must follow consistent naming. `assetName` should match `id`.

## Reference IDs

Patterns:

- Scales: `scale_<key>_<scaletype>_pos<position>`  
  - e.g. `scale_am_pentatonic_pos1`
- Chords: `chord_<root>_<quality>_<shape>`  
  - e.g. `chord_g_major_open`
- Techniques: `tech_<category>_<slug>`  
  - e.g. `tech_bends_basic`
- Songs: `song_<slug>_<section>`  
  - e.g. `song_oasis_wonderwall_verse`

Rules:
- All lowercase.  
- Words separated by `_`.  
- `key` examples: `am`, `em`, `c`, `g`.  
- `section` examples: `intro`, `verse`, `chorus`, `riff`.

---

# 11. Reference Diagram Library

Reference IDs follow naming patterns in Section 10. Initial catalog: 5 Am pentatonic positions, 4 basic open chords (Am, C, G, E), 3 technique diagrams (bends, vibrato, alternate picking). See asset catalog and code for full list.

---

# 12. Metronome Rules

When to recommend metronome:

- Warm‑Up → ON by default.  
- Technique → ON recommended.  
- Song → OFF by default, optional ON.  
- Solo → OFF by default, optional ON.

UI rules:
- Use `metronome` SF Symbol only.  
- Do not show the word "Metronome".  
- Show numeric BPM and +/- icons only.
- Record starting/ending BPM and +/- taps for metronome-on blocks to feed tempo learning.

---

# 13. Navigation (Sidebar)

- Top-left hamburger in the title bar opens a left sidebar; center title stays visible.
- Sidebar items (one word): **Today**, **Profile**, **History**, **Settings**.
- Active item uses the app accent; others use secondary label color.
- Sidebar slides over the current screen with a dimmed backdrop; dismiss by tapping outside or swiping left.
- No bottom tab bar on Today or related screens.

---

# 14. Screen Compositions & Components

## Today Screen Composition

- Title bar: left hamburger, centered “Today” title.
- Content uses `BlockListView` cards with tighter vertical spacing (light gaps, no large paddings between cards) while keeping cards readable.
- Primary CTA remains start/resume session; avoid extra labels or subtitles.

## Practice Screen Composition

The Practice screen uses these components:

- `PracticeTimerView`  
  - Renders concentric rings and central timer content.
- `MetronomeBar`  
  - Renders the icon‑based metronome row.
- Preview state  
  - 10s countdown before each block; tap anywhere to start immediately.
- Bottom control row  
  - Three buttons: Skip, +2:00, Finish.
- Instruction card  
  - Tap to open sheet with full bullets and diagram if available.

Layout:

```text
VStack
  HStack: [Block kind label]   [questionmark.circle?]
  (Preview: 10s countdown, tap to start)
  PracticeTimerView
  MetronomeBar
  HStack: [Skip] [+2:00] [Finish]
  Instruction card (tappable)
```

## Feedback Screen Composition

Uses `FeedbackBar`:

- "How was that?" text.  
- [Easy] [Good] [Hard] buttons.  
- Below: [Next block] or [Done] primary button.

No additional help text or explanations.

---

# 15. Session Summary

After all blocks are completed, show a minimal summary.

Layout:

```text
Session complete

Warm‑Up: Good
Fretboard: Good
Song: Hard
Solo: Good
Technique: Easy
Fun ending: Good

Total: 38 min

[Close]
```

No charts, no streak gamification in v1 (can be added later).

---

# 16. History Tab

History shows past sessions in a simple list (or calendar later):

```text
History

Sun 23 — 38 min
Sat 22 — 12 min
Fri 21 — 40 min
```

Tapping an entry → Session detail:

```text
November 23, 2025

Warm‑Up: Good
Song: Hard
Solo: Good
Technique: Easy

Total: 38 min
```

---

# 17. Settings Tab

Minimal list:

```text
Settings

Level >
Styles >
Block length >
Cues >
Manage songs >
```

Each row leads to a simple, focused screen.

---

# 18. Modularity Reminder

All screens must be built from small, composable components:

- Do not build monolithic UIs with deeply nested logic.  
- Extract new components when layout becomes complex or reused.  
- Any new reusable visual pattern should be:
  - Documented here in `design.md`.  
  - Promoted to a named SwiftUI component in `architecture.md`.

Any change that affects user flows or layout should first update this design guide,
then update the implementation.
