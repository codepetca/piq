# SmartJam — Backing Tracks for Solo/Technique

SmartJam attaches a light backing track to jam-capable blocks without changing the UI or core loop.

- **Applies to:** Solo and Technique blocks (optionally Song later). Warm-Up blocks stay quiet.
- **Inputs:** block kind, optional key, optional BPM hint, and user style preferences (rock / pop / blues / R&B / worship).
- **Selection:** A deterministic catalog lookup chooses a pattern family by category + preferred style; closest base BPM wins, with a slight preference for key matches when provided.
- **Config:** Each block may carry a `SmartJamConfig` (family ID, asset name, target key/BPM, base BPM, style/category).
- **Playback:** The AudioHaptics SmartJamAudioService loops a bundled asset; pause/resume/stop follow the block pause/finish/skip states. No extra UI controls in v1.
- **Assets:** Catalog uses stub asset names like `sj_blues_solo_90_full`; real audio can replace them later without code changes.
