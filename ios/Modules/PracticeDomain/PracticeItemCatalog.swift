import Foundation

enum PracticeItemCatalog {
    static func seedItems(now: Date = Date()) -> [PracticeItem] {
        let baseState = SRSState(stability: 1.5, nextDue: now)

        return [
            PracticeItem(catalogID: "warmup_chromatic", category: .warmup, title: "Chromatic Warm-Up", detail: "1-4 frets", referenceID: "warmup_chromatic", srs: baseState),
            PracticeItem(catalogID: "warmup_spider", category: .warmup, title: "Spider Exercise", detail: "Ascending/descending", referenceID: "warmup_spider", srs: baseState),
            PracticeItem(catalogID: "fretboard_note_naming", category: .fretboard, title: "Note Naming", detail: "E & A strings", srs: baseState),
            PracticeItem(catalogID: "fretboard_octave_shapes", category: .fretboard, title: "Octave Shapes", detail: "Across neck", srs: baseState),
            PracticeItem(catalogID: "repertoire_wonderwall", category: .repertoire, title: "Wonderwall", detail: "Full song", key: "Em", srs: baseState),
            PracticeItem(catalogID: "repertoire_nothing_else_matters", category: .repertoire, title: "Nothing Else Matters", detail: "Intro", key: "Em", srs: baseState),
            PracticeItem(catalogID: "repertoire_hotel_california", category: .repertoire, title: "Hotel California", detail: "Chorus", key: "Bm", srs: baseState),
            PracticeItem(catalogID: "songwork_blackbird", category: .songwork, title: "Blackbird", detail: "Fingerstyle", key: "G", srs: baseState),
            PracticeItem(catalogID: "songwork_stand_by_me", category: .songwork, title: "Stand By Me", detail: "Verse groove", key: "A", srs: baseState),
            PracticeItem(catalogID: "soloing_am_pentatonic_pos1", category: .soloing, title: "Am Pentatonic", detail: "Position 1", key: "Am", referenceID: "scale_am_pentatonic_pos1", srs: baseState),
            PracticeItem(catalogID: "soloing_em_pentatonic_pos2", category: .soloing, title: "Em Pentatonic", detail: "Position 2", key: "Em", srs: baseState),
            PracticeItem(catalogID: "soloing_blues_licks_box1", category: .soloing, title: "Blues Licks", detail: "Box 1", key: "Am", referenceID: "licks_blues_box1", srs: baseState),
            PracticeItem(catalogID: "technique_alt_picking", category: .technique, title: "Alternate Picking", detail: "Eighth notes", referenceID: "technique_alt_picking", srs: baseState),
            PracticeItem(catalogID: "technique_legato", category: .technique, title: "Hammer-Ons & Pull-Offs", detail: "Two-string", srs: baseState),
            PracticeItem(catalogID: "theory_major_scale_degrees", category: .theory, title: "Major Scale Degrees", detail: "Key of C", srs: baseState),
            PracticeItem(catalogID: "theory_triad_inversions", category: .theory, title: "Triad Inversions", detail: "CAGED", srs: baseState),
            PracticeItem(catalogID: "rhythm_strumming_patterns", category: .rhythm, title: "Strumming Patterns", detail: "1 e & a", srs: baseState),
            PracticeItem(catalogID: "rhythm_syncopation", category: .rhythm, title: "Syncopation", detail: "Backbeat focus", srs: baseState),
            PracticeItem(catalogID: "chords_barre_transitions", category: .chords, title: "Barre Chord Transitions", detail: "E-shape", srs: baseState),
            PracticeItem(catalogID: "chords_open_switches", category: .chords, title: "Open Chord Switches", detail: "G-Em-C-D", srs: baseState)
        ]
    }
}
