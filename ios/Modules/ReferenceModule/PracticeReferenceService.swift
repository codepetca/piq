import Foundation

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

            // Scale references
            PracticeReference(
                id: "scale_am_pentatonic_pos1",
                title: "Am Pentatonic - Position 1",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=am+pentatonic+scale+position+1")
            ),

            // Lick references
            PracticeReference(
                id: "licks_blues_box1",
                title: "Blues Licks - Box 1",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=blues+licks+box+1")
            ),

            // Technique references
            PracticeReference(
                id: "tech_bends_basic",
                title: "Basic Bending Technique",
                externalURL: URL(string: "https://www.youtube.com/results?search_query=guitar+bending+technique")
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
            )
        ]

        for ref in demoReferences {
            references[ref.id] = ref
        }
    }
}
