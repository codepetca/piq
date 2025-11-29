# piq Product Roadmap (Source of Truth)

Last updated: 2025-11-29  
Scope: what to build and when. Why/how live in `/docs/guidance/guidance.md` and `/docs/core/`.

---

## Development Workflow
roadmap.md → GitHub issues (/docs/issues/* or GitHub) → implementation

Roadmap changes are rare and intentional. Iteration detail belongs in issues.

---

## Status Legend
- **Shipped**: in code now
- **Next**: MVP-completion focus
- **Future**: queued after MVP
- **Explorations**: evaluate later

---

## Foundations (Shipped)
- Seed catalog (~38 items) across 11 categories with instructions/focus cues and references.
- Spaced Repetition Engine: stability-based ordering, due/priority queries, feedback application, tempo learning.
- Session generation: 6–8 microblocks (~30–40 min) with warmup first, interleaved middle, fun ending; suggested BPM for metronome-on blocks.
- PracticeEngine: preview → inBlock → betweenBlocks → finished; pause/extend/adjust/skip; feedback capture; timer ownership.
- Tempo & feedback loop: MetronomeService + HapticService, starting/ending BPM capture, tempo adjustment tracking.
- Persistence v2: sessions + SRS/tempo state saved/loaded; merge seed catalog with stored state; history stats/trends.
- UI flows: sidebar RootView; Today (reorder/remove, resume active session); Practice session with preview + instructions card + metronome; Feedback step; History list/stats; Settings (BPM, haptics, reset/clear data).

---

## Phase 1 – MVP Completion (Next)
Goal: ship a coherent daily practice coach with reliable 6–8 microblocks and onboarding.

- Confirm and document the 6–8 microblock structure (durations per category) across design/architecture/guidance/UI copy.
- Onboarding (planned): level, styles, cues → seed preferences and initial catalog emphasis.
- Session polish: summary screen clarity (feedback + minutes), safer state handling/resume, align Today/Practice UI to microblock structure.
- Reliability: tighten PracticeEngine/SRE/storage tests; handle empty/edge cases; ensure persistence schema v2 is stable.
- References: ensure question-mark affordance and sheets cover existing catalog.

**Done when:** user can onboard, get 6–8 guided microblocks daily, complete with metronome/haptics, give feedback, see history saved, and state resumes safely.

---

## Phase 2 – Enhanced Experience (Future)
Goal: customization and insight.

- Custom practice items (user-created) using same SRE/tempo pipelines.
- History depth: calendar/list hybrid, streaks/trends, per-category stats.
- Settings depth: block duration preferences, metronome defaults, category preferences.
- Reference richness: more diagrams + succinct hints; optional external links.
- Summary improvements: stability/next-due hints; minimal streak view; still no teaching text.

---

## Phase 3 – Explorations (Evaluate after Phase 2)
- watchOS companion for quick blocks and reminders.
- Widgets (today’s due skills, quick start).
- Import/export for SRS/tempo state and custom items.
- Audio/haptics refinements (patterns, improved timing).
- Any AI coach/backing-track/gamification ideas remain exploratory until core experience is solid.

---

## Constraints (All Phases)
- **design.md** — minimal, calm UI; SF Symbols; no teaching walls of text.
- **architecture.md** — SwiftUI + Observation; engines own logic/timers; module boundaries.
- **agents.md** — role separation and ownership.
- **tests.md** — engines/storage first; TDD-leaning for logic.
- **guidance.md** — learning model, skill catalog, interleaving/SRS rules.
