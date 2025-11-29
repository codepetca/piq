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
            path: "ios/Modules",
            exclude: [
                "ReferenceModule/PracticeReferenceView.swift",
                "SessionUI",
                "AudioHapticsModule",
                "HistoryModule",
                "SettingsModule",
                "OnboardingModule/OnboardingView.swift"
            ],
            sources: [
                "PracticeDomain/HistoryTrendCalculator.swift",
                "PracticeDomain/PracticeBlock.swift",
                "PracticeDomain/PracticeBlockFeedback.swift",
                "PracticeDomain/PracticeBlockKind.swift",
                "PracticeDomain/PracticeEngine.swift",
                "PracticeDomain/PracticeItem.swift",
                "PracticeDomain/PracticeItemCatalog.swift",
                "PracticeDomain/PracticeItemCategory.swift",
                "PracticeDomain/PracticeSession.swift",
                "PracticeDomain/PracticeStorage.swift",
                "PracticeDomain/SpacedRepetitionEngine.swift",
                "PracticeDomain/TempoEngine.swift",
                "PracticeDomain/UserPreferences.swift",
                "TodayModule/TodayViewModel.swift",
                "OnboardingModule/OnboardingViewModel.swift"
            ]
        ),
        .target(
            name: "ReferenceModule",
            path: "ios/Modules/ReferenceModule",
            exclude: ["PracticeReferenceView.swift"],
            sources: ["PracticeReference.swift", "PracticeReferenceService.swift"]
        ),
        .testTarget(
            name: "piqTests",
            dependencies: ["piq"],
            path: "ios/Tests/PracticeDomainTests"
        ),
        .testTarget(
            name: "TodayModuleTests",
            dependencies: ["piq"],
            path: "ios/Tests/TodayModuleTests"
        ),
        .testTarget(
            name: "ReferenceModuleTests",
            dependencies: ["ReferenceModule"],
            path: "ios/Tests/ReferenceModuleTests"
        ),
        .testTarget(
            name: "OnboardingModuleTests",
            dependencies: ["piq"],
            path: "ios/Tests/OnboardingModuleTests"
        )
    ]
)
