import Foundation
import Observation

/// Service that provides reference diagrams and guides for practice items.
@Observable
final class PracticeReferenceService {
    private var references: [String: PracticeReference] = [:]

    init() {
        loadDemoReferences()
    }

    /// Returns the reference for a given ID, if it exists.
    func reference(for id: String) -> PracticeReference? {
        references[id]
    }

    /// Returns all available references.
    var allReferences: [PracticeReference] {
        Array(references.values).sorted { $0.title < $1.title }
    }

    private func loadDemoReferences() {
        let demoReferences: [PracticeReference] = [
            // Warm-up references
            PracticeReference(
                id: "warmup_chromatic",
                title: "Chromatic Warm-Up",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=guitar+chromatic+warmup")
            ),
            PracticeReference(
                id: "warmup_spider",
                title: "Spider Exercise",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=guitar+spider+exercise")
            ),

            // Am pentatonic scale references (5 positions)
            PracticeReference(
                id: "scale_am_pentatonic_pos1",
                title: "Am Pentatonic – pos 1",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=am+pentatonic+scale+position+1")
            ),
            PracticeReference(
                id: "scale_am_pentatonic_pos2",
                title: "Am Pentatonic – pos 2",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=am+pentatonic+scale+position+2")
            ),
            PracticeReference(
                id: "scale_am_pentatonic_pos3",
                title: "Am Pentatonic – pos 3",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=am+pentatonic+scale+position+3")
            ),
            PracticeReference(
                id: "scale_am_pentatonic_pos4",
                title: "Am Pentatonic – pos 4",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=am+pentatonic+scale+position+4")
            ),
            PracticeReference(
                id: "scale_am_pentatonic_pos5",
                title: "Am Pentatonic – pos 5",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=am+pentatonic+scale+position+5")
            ),

            // Basic open chord references
            PracticeReference(
                id: "chord_am_open",
                title: "Am Chord – open",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=am+chord+guitar")
            ),
            PracticeReference(
                id: "chord_c_major_open",
                title: "C Major – open",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=c+major+chord+guitar")
            ),
            PracticeReference(
                id: "chord_g_major_open",
                title: "G Major – open",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=g+major+chord+guitar")
            ),
            PracticeReference(
                id: "chord_e_major_open",
                title: "E Major – open",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=e+major+chord+guitar")
            ),

            // Lick references
            PracticeReference(
                id: "licks_blues_box1",
                title: "Blues Licks – Box 1",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=blues+licks+box+1")
            ),

            // Technique references
            PracticeReference(
                id: "tech_bends_basic",
                title: "Bends – basic",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=guitar+bending+technique")
            ),
            PracticeReference(
                id: "tech_vibrato_basic",
                title: "Vibrato – basic",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=guitar+vibrato+technique")
            ),
            PracticeReference(
                id: "technique_alt_picking",
                title: "Alternate Picking",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=alternate+picking+technique")
            ),
            PracticeReference(
                id: "technique_chord_transitions",
                title: "Chord Transitions",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=guitar+chord+transition+practice")
            ),
            PracticeReference(
                id: "technique_legato",
                title: "Legato – basic",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=guitar+legato+technique")
            )
        ]

        for ref in demoReferences {
            references[ref.id] = ref
        }
    }
}
