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
            targets: ["piq"]
        )
    ],
    targets: [
        .target(
            name: "piq",
            path: "ios/Modules/PracticeDomain"
        ),
        .testTarget(
            name: "piqTests",
            dependencies: ["piq"],
            path: "ios/Tests/PracticeDomainTests"
        )
    ]
)
