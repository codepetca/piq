import XCTest
@testable import piq
@testable import ReferenceModule

final class ReferenceCoverageTests: XCTestCase {

    func testAllCatalogReferenceIDsResolve() {
        let items = PracticeItemCatalog.seedItems()
        let referenceIDs = Set(items.compactMap { $0.referenceID })
        let service = PracticeReferenceService()

        for id in referenceIDs {
            XCTAssertNotNil(service.reference(for: id), "Reference \(id) should be registered in PracticeReferenceService")
        }
    }

    func testAssetsExistForCatalogReferences() {
        let items = PracticeItemCatalog.seedItems()
        let referenceIDs = Set(items.compactMap { $0.referenceID })

        let assetsDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // ReferenceCoverageTests.swift parent
            .deletingLastPathComponent() // PracticeDomainTests
            .deletingLastPathComponent() // Tests
            .appendingPathComponent("Assets.xcassets")

        XCTAssertTrue(
            FileManager.default.fileExists(atPath: assetsDirectory.path),
            "Assets.xcassets directory should exist at \(assetsDirectory.path)"
        )

        for id in referenceIDs {
            let imagesetPath = assetsDirectory
                .appendingPathComponent("\(id).imageset")
                .path

            XCTAssertTrue(
                FileManager.default.fileExists(atPath: imagesetPath),
                "Missing imageset for reference \(id) at \(imagesetPath)"
            )
        }
    }
}
