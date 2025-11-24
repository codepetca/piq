import Foundation

/// A reference diagram or guide that can be shown during practice.
///
/// References are linked to practice items via `referenceID` and provide
/// visual aids like scale diagrams, chord charts, or technique guides.
struct PracticeReference: Identifiable, Codable, Equatable {
    /// Unique identifier (e.g., "scale_am_pentatonic_pos1")
    let id: String

    /// Display title (e.g., "Am Pentatonic - Position 1")
    let title: String

    /// Asset name in the asset catalog (typically same as id)
    let assetName: String

    /// Optional external lesson URL (e.g., YouTube tutorial)
    let externalURL: URL?

    init(
        id: String,
        title: String,
        assetName: String? = nil,
        externalURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.assetName = assetName ?? id
        self.externalURL = externalURL
    }
}
