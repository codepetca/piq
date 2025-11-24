# Issue 013: Settings Enhancements (Block Length & Metronome Defaults)

## 1. Purpose
Extend the Settings tab to allow users to adjust key practice parameters (block length defaults and metronome defaults) while keeping the UI simple and aligned with `design.md`.

## 2. Relevant Documentation
Before working on this issue, the AI must read:

1. `/docs/core/design.md`
2. `/docs/core/claude.md`
3. `/docs/core/agents.md`
4. `/docs/core/tests.md`
5. `/docs/guidance/piq-guitar-guidance.md`
6. `/docs/core/roadmap.md`
7. This issue file.

## 3. Requirements
- Add options in Settings to configure:
  - Default block length (within a small set of options, e.g., 2, 3, 5, 8 minutes).
  - Metronome defaults:
    - ON/OFF for Warm-Up and Technique blocks.
    - OFF/optional for Song and Solo blocks.
- UI:
  - Simple list rows with short labels as per `design.md`.
  - Use toggles or pickers with minimal copy.
- Wiring:
  - Save these preferences via `PracticeStorage` or a dedicated preferences storage.
  - Ensure session generation and practice UI respect these settings.

## 4. Implementation Notes (Optional)
- Keep Settings logic in `SettingsModule` or equivalent.
- Default values should reflect the research-backed defaults:
  - Short block lengths (2–5 minutes).
  - Metronome ON by default for technique / warm-up.
- Preferences can be simple key-value storage; no need for complex schemas.

## 5. Testing Requirements
- Storage tests:
  - Preferences save and load correctly.
- Domain/UI logic tests:
  - Session generation uses chosen block length.
  - Metronome starts in the correct default state per block type.

## 6. Deliverables
- Updated Settings UI with new options.
- Persistence logic for these settings.
- Updated code paths that read and apply these settings during session creation and practice.

## 7. Do NOT
- Do NOT clutter Settings with advanced or experimental options.
- Do NOT add new tabs or navigation flows.
- Do NOT add explanatory paragraphs or tutorials in Settings.
