import XCTest
@testable import ReferenceModule

final class PracticeReferenceServiceTests: XCTestCase {

    // MARK: - Initialization Tests

    func testServiceInitializesWithReferences() {
        let service = PracticeReferenceService()
        XCTAssertFalse(service.allReferences.isEmpty, "Service should load references on init")
    }

    // MARK: - Reference Lookup Tests

    func testReferenceForValidIDReturnsReference() {
        let service = PracticeReferenceService()
        let reference = service.reference(for: "scale_am_pentatonic_pos1")

        XCTAssertNotNil(reference)
        XCTAssertEqual(reference?.id, "scale_am_pentatonic_pos1")
        XCTAssertEqual(reference?.title, "Am Pentatonic – pos 1")
        XCTAssertEqual(reference?.assetName, "scale_am_pentatonic_pos1")
    }

    func testReferenceForInvalidIDReturnsNil() {
        let service = PracticeReferenceService()
        let reference = service.reference(for: "nonexistent_reference")

        XCTAssertNil(reference)
    }

    // MARK: - Am Pentatonic Scale Position Tests

    func testAllAmPentatonicPositionsExist() {
        let service = PracticeReferenceService()

        for position in 1...5 {
            let refID = "scale_am_pentatonic_pos\(position)"
            let reference = service.reference(for: refID)
            XCTAssertNotNil(reference, "Am pentatonic position \(position) should exist")
            XCTAssertEqual(reference?.id, refID)
            XCTAssertTrue(reference?.title.contains("Am Pentatonic") == true, "Title should contain 'Am Pentatonic'")
            XCTAssertTrue(reference?.title.contains("pos \(position)") == true, "Title should contain position number")
        }
    }

    // MARK: - Open Chord Reference Tests

    func testBasicOpenChordReferencesExist() {
        let service = PracticeReferenceService()

        let chords = [
            ("chord_am_open", "Am Chord"),
            ("chord_c_major_open", "C Major"),
            ("chord_g_major_open", "G Major"),
            ("chord_e_major_open", "E Major")
        ]

        for (refID, expectedTitleContains) in chords {
            let reference = service.reference(for: refID)
            XCTAssertNotNil(reference, "\(refID) should exist")
            XCTAssertEqual(reference?.id, refID)
            XCTAssertTrue(reference?.title.contains(expectedTitleContains) == true, "Title should contain '\(expectedTitleContains)'")
        }
    }

    // MARK: - Technique Reference Tests

    func testTechniqueReferencesExist() {
        let service = PracticeReferenceService()

        let techniques = [
            "tech_bends_basic",
            "tech_vibrato_basic",
            "technique_alt_picking"
        ]

        for refID in techniques {
            let reference = service.reference(for: refID)
            XCTAssertNotNil(reference, "\(refID) should exist")
        }
    }

    // MARK: - Asset Name Tests

    func testAssetNameMatchesIDByDefault() {
        let service = PracticeReferenceService()

        for reference in service.allReferences {
            XCTAssertEqual(reference.assetName, reference.id, "Asset name should match ID for \(reference.id)")
        }
    }

    // MARK: - External URL Tests

    func testReferencesHaveExternalURLs() {
        let service = PracticeReferenceService()

        // All demo references should have external URLs
        for reference in service.allReferences {
            XCTAssertNotNil(reference.externalURL, "Reference \(reference.id) should have an external URL")
        }
    }

    // MARK: - Warm-up Reference Tests

    func testWarmupReferencesExist() {
        let service = PracticeReferenceService()

        let warmups = ["warmup_chromatic", "warmup_spider"]
        for refID in warmups {
            let reference = service.reference(for: refID)
            XCTAssertNotNil(reference, "\(refID) should exist")
        }
    }

    // MARK: - All References Count Test

    func testAllReferencesCount() {
        let service = PracticeReferenceService()

        // Should have at least: 2 warmups + 5 scales + 4 chords + 5 techniques + 1 lick = 17 references
        XCTAssertGreaterThanOrEqual(service.allReferences.count, 17, "Should have at least 17 references")
    }

    // MARK: - Reference Sorting Tests

    func testAllReferencesAreSortedByTitle() {
        let service = PracticeReferenceService()
        let references = service.allReferences

        let titles = references.map { $0.title }
        let sortedTitles = titles.sorted()

        XCTAssertEqual(titles, sortedTitles, "References should be sorted by title")
    }
}
