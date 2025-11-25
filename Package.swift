// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "piq",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "piq",
            targets: ["piq", "ReferenceModule"]
        )
    ],
    targets: [
        .target(
            name: "piq",
            path: "ios/Modules/PracticeDomain"
        ),
        .target(
            name: "ReferenceModule",
            path: "ios/Modules/ReferenceModule",
            sources: ["PracticeReference.swift", "PracticeReferenceService.swift"]
        ),
        .testTarget(
            name: "piqTests",
            dependencies: ["piq"],
            path: "ios/Tests/PracticeDomainTests"
        ),
        .testTarget(
            name: "ReferenceModuleTests",
            dependencies: ["ReferenceModule"],
            path: "ios/Tests/ReferenceModuleTests"
        )
    ]
)
