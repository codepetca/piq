import Foundation

enum PracticeItemCatalog {
    static func seedItems(now: Date = Date()) -> [PracticeItem] {
        let baseState = SRSState(stability: 1.5, nextDue: now)

        return [
            // Warm-up items
            PracticeItem(catalogID: "warmup_chromatic", category: .warmup, title: "Chromatic Warm-Up", detail: "1-4 frets", referenceID: "warmup_chromatic", srs: baseState),
            PracticeItem(catalogID: "warmup_spider", category: .warmup, title: "Spider Exercise", detail: "Ascending/descending", referenceID: "warmup_spider", srs: baseState),

            // Fretboard items
            PracticeItem(catalogID: "fretboard_note_naming", category: .fretboard, title: "Note Naming", detail: "E & A strings", srs: baseState),
            PracticeItem(catalogID: "fretboard_octave_shapes", category: .fretboard, title: "Octave Shapes", detail: "Across neck", srs: baseState),

            // Repertoire items
            PracticeItem(catalogID: "repertoire_wonderwall", category: .repertoire, title: "Wonderwall", detail: "Full song", key: "Em", srs: baseState),
            PracticeItem(catalogID: "repertoire_nothing_else_matters", category: .repertoire, title: "Nothing Else Matters", detail: "Intro", key: "Em", srs: baseState),
            PracticeItem(catalogID: "repertoire_hotel_california", category: .repertoire, title: "Hotel California", detail: "Chorus", key: "Bm", srs: baseState),

            // Songwork items
            PracticeItem(catalogID: "songwork_blackbird", category: .songwork, title: "Blackbird", detail: "Fingerstyle", key: "G", srs: baseState),
            PracticeItem(catalogID: "songwork_stand_by_me", category: .songwork, title: "Stand By Me", detail: "Verse groove", key: "A", srs: baseState),

            // Soloing items (Am pentatonic all 5 positions)
            PracticeItem(catalogID: "soloing_am_pentatonic_pos1", category: .soloing, title: "Am Pentatonic", detail: "Position 1", key: "Am", referenceID: "scale_am_pentatonic_pos1", srs: baseState),
            PracticeItem(catalogID: "soloing_am_pentatonic_pos2", category: .soloing, title: "Am Pentatonic", detail: "Position 2", key: "Am", referenceID: "scale_am_pentatonic_pos2", srs: baseState),
            PracticeItem(catalogID: "soloing_am_pentatonic_pos3", category: .soloing, title: "Am Pentatonic", detail: "Position 3", key: "Am", referenceID: "scale_am_pentatonic_pos3", srs: baseState),
            PracticeItem(catalogID: "soloing_am_pentatonic_pos4", category: .soloing, title: "Am Pentatonic", detail: "Position 4", key: "Am", referenceID: "scale_am_pentatonic_pos4", srs: baseState),
            PracticeItem(catalogID: "soloing_am_pentatonic_pos5", category: .soloing, title: "Am Pentatonic", detail: "Position 5", key: "Am", referenceID: "scale_am_pentatonic_pos5", srs: baseState),
            PracticeItem(catalogID: "soloing_em_pentatonic_pos2", category: .soloing, title: "Em Pentatonic", detail: "Position 2", key: "Em", srs: baseState),
            PracticeItem(catalogID: "soloing_blues_licks_box1", category: .soloing, title: "Blues Licks", detail: "Box 1", key: "Am", referenceID: "licks_blues_box1", srs: baseState),

            // Technique items
            PracticeItem(catalogID: "technique_alt_picking", category: .technique, title: "Alternate Picking", detail: "Eighth notes", referenceID: "technique_alt_picking", srs: baseState),
            PracticeItem(catalogID: "technique_legato", category: .technique, title: "Hammer-Ons & Pull-Offs", detail: "Two-string", referenceID: "technique_legato", srs: baseState),
            PracticeItem(catalogID: "technique_bends", category: .technique, title: "String Bending", detail: "Half & whole step", referenceID: "tech_bends_basic", srs: baseState),
            PracticeItem(catalogID: "technique_vibrato", category: .technique, title: "Vibrato", detail: "Wrist control", referenceID: "tech_vibrato_basic", srs: baseState),

            // Theory items
            PracticeItem(catalogID: "theory_major_scale_degrees", category: .theory, title: "Major Scale Degrees", detail: "Key of C", srs: baseState),
            PracticeItem(catalogID: "theory_triad_inversions", category: .theory, title: "Triad Inversions", detail: "CAGED", srs: baseState),

            // Rhythm items
            PracticeItem(catalogID: "rhythm_strumming_patterns", category: .rhythm, title: "Strumming Patterns", detail: "1 e & a", srs: baseState),
            PracticeItem(catalogID: "rhythm_syncopation", category: .rhythm, title: "Syncopation", detail: "Backbeat focus", srs: baseState),

            // Chord items
            PracticeItem(catalogID: "chords_barre_transitions", category: .chords, title: "Barre Chord Transitions", detail: "E-shape", srs: baseState),
            PracticeItem(catalogID: "chords_open_switches", category: .chords, title: "Open Chord Switches", detail: "G-Em-C-D", referenceID: "technique_chord_transitions", srs: baseState),
            PracticeItem(catalogID: "chords_am_open", category: .chords, title: "Am Chord", detail: "Open position", referenceID: "chord_am_open", srs: baseState),
            PracticeItem(catalogID: "chords_c_major_open", category: .chords, title: "C Major Chord", detail: "Open position", referenceID: "chord_c_major_open", srs: baseState),
            PracticeItem(catalogID: "chords_g_major_open", category: .chords, title: "G Major Chord", detail: "Open position", referenceID: "chord_g_major_open", srs: baseState),
            PracticeItem(catalogID: "chords_e_major_open", category: .chords, title: "E Major Chord", detail: "Open position", referenceID: "chord_e_major_open", srs: baseState),

            // Ear training items
            PracticeItem(catalogID: "ear_training_major_minor", category: .ear_training, title: "Major or Minor?", detail: "Key feel check", srs: baseState),
            PracticeItem(catalogID: "ear_training_hum_root", category: .ear_training, title: "Hum & Match Root", detail: "Find the tonic", srs: baseState),
            PracticeItem(catalogID: "ear_training_straight_swing", category: .ear_training, title: "Straight vs Swing", detail: "Feel the groove", srs: baseState),
            PracticeItem(catalogID: "ear_training_interval_feel", category: .ear_training, title: "Interval Feel", detail: "Recognize intervals", srs: baseState),

            // Musicality items
            PracticeItem(catalogID: "musicality_dynamics", category: .musicality, title: "Dynamic Control", detail: "Quiet → loud", srs: baseState),
            PracticeItem(catalogID: "musicality_slow_vibrato", category: .musicality, title: "Controlled Vibrato", detail: "Slow & expressive", srs: baseState),
            PracticeItem(catalogID: "musicality_bend_accuracy", category: .musicality, title: "Bend Accuracy", detail: "Half-step precision", srs: baseState),
            PracticeItem(catalogID: "musicality_tone_touch", category: .musicality, title: "Tone & Touch", detail: "Pick attack variation", srs: baseState)
        ]
    }
}
