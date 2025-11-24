import Foundation

enum PracticeItemCatalog {
    static func seedItems(now: Date = Date()) -> [PracticeItem] {
        let baseState = SRSState(stability: 1.5, nextDue: now)

        return [
            PracticeItem(category: .warmup, title: "Chromatic Warm-Up", detail: "1-4 frets", referenceID: "warmup_chromatic", srs: baseState),
            PracticeItem(category: .warmup, title: "Spider Exercise", detail: "Ascending/descending", referenceID: "warmup_spider", srs: baseState),
            PracticeItem(category: .fretboard, title: "Note Naming", detail: "E & A strings", srs: baseState),
            PracticeItem(category: .fretboard, title: "Octave Shapes", detail: "Across neck", srs: baseState),
            PracticeItem(category: .repertoire, title: "Wonderwall", detail: "Full song", key: "Em", srs: baseState),
            PracticeItem(category: .repertoire, title: "Nothing Else Matters", detail: "Intro", key: "Em", srs: baseState),
            PracticeItem(category: .repertoire, title: "Hotel California", detail: "Chorus", key: "Bm", srs: baseState),
            PracticeItem(category: .songwork, title: "Blackbird", detail: "Fingerstyle", key: "G", srs: baseState),
            PracticeItem(category: .songwork, title: "Stand By Me", detail: "Verse groove", key: "A", srs: baseState),
            PracticeItem(category: .soloing, title: "Am Pentatonic", detail: "Position 1", key: "Am", referenceID: "scale_am_pentatonic_pos1", srs: baseState),
            PracticeItem(category: .soloing, title: "Em Pentatonic", detail: "Position 2", key: "Em", srs: baseState),
            PracticeItem(category: .soloing, title: "Blues Licks", detail: "Box 1", key: "Am", referenceID: "licks_blues_box1", srs: baseState),
            PracticeItem(category: .technique, title: "Alternate Picking", detail: "Eighth notes", referenceID: "technique_alt_picking", srs: baseState),
            PracticeItem(category: .technique, title: "Hammer-Ons & Pull-Offs", detail: "Two-string", srs: baseState),
            PracticeItem(category: .theory, title: "Major Scale Degrees", detail: "Key of C", srs: baseState),
            PracticeItem(category: .theory, title: "Triad Inversions", detail: "CAGED", srs: baseState),
            PracticeItem(category: .rhythm, title: "Strumming Patterns", detail: "1 e & a", srs: baseState),
            PracticeItem(category: .rhythm, title: "Syncopation", detail: "Backbeat focus", srs: baseState),
            PracticeItem(category: .chords, title: "Barre Chord Transitions", detail: "E-shape", srs: baseState),
            PracticeItem(category: .chords, title: "Open Chord Switches", detail: "G-Em-C-D", srs: baseState)
        ]
    }
}
