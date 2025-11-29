import XCTest
@testable import piq

final class OnboardingViewModelTests: XCTestCase {

    var tempDirectory: URL!
    var storage: PracticeStorage!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        storage = PracticeStorage(directory: tempDirectory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialState() {
        let viewModel = OnboardingViewModel(storage: storage)

        XCTAssertEqual(viewModel.currentStep, .welcome)
        XCTAssertEqual(viewModel.selectedLevel, .beginner)
        XCTAssertTrue(viewModel.selectedStyles.isEmpty)
        XCTAssertEqual(viewModel.selectedCuePreference, .soundAndVibration)
        XCTAssertTrue(viewModel.previewBlocks.isEmpty)
    }

    // MARK: - Step Navigation

    func testNavigationFromWelcome() {
        let viewModel = OnboardingViewModel(storage: storage)

        XCTAssertEqual(viewModel.currentStep, .welcome)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .level)
    }

    func testNavigationFromLevel() {
        let viewModel = OnboardingViewModel(storage: storage)
        viewModel.nextStep() // Welcome -> Level

        XCTAssertEqual(viewModel.currentStep, .level)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .styles)
    }

    func testNavigationFromStylesRequiresSelection() {
        let viewModel = OnboardingViewModel(storage: storage)
        viewModel.nextStep() // Welcome -> Level
        viewModel.nextStep() // Level -> Styles

        XCTAssertEqual(viewModel.currentStep, .styles)
        XCTAssertFalse(viewModel.canProceed) // No styles selected

        viewModel.nextStep() // Should not proceed
        XCTAssertEqual(viewModel.currentStep, .styles)

        // Select a style
        viewModel.toggleStyle(.rock)
        XCTAssertTrue(viewModel.canProceed)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .cues)
    }

    func testNavigationFromCuesToSummary() {
        let viewModel = OnboardingViewModel(storage: storage)
        viewModel.nextStep() // Welcome -> Level
        viewModel.nextStep() // Level -> Styles
        viewModel.toggleStyle(.blues)
        viewModel.nextStep() // Styles -> Cues

        XCTAssertEqual(viewModel.currentStep, .cues)

        viewModel.nextStep()
        XCTAssertEqual(viewModel.currentStep, .summary)
        XCTAssertFalse(viewModel.previewBlocks.isEmpty)
    }

    func testBackNavigation() {
        let viewModel = OnboardingViewModel(storage: storage)
        viewModel.nextStep() // Welcome -> Level
        viewModel.nextStep() // Level -> Styles

        XCTAssertEqual(viewModel.currentStep, .styles)

        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .level)

        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .welcome)

        // Can't go back from welcome
        viewModel.previousStep()
        XCTAssertEqual(viewModel.currentStep, .welcome)
    }

    // MARK: - Style Selection

    func testToggleStyle() {
        let viewModel = OnboardingViewModel(storage: storage)

        XCTAssertTrue(viewModel.selectedStyles.isEmpty)

        viewModel.toggleStyle(.rock)
        XCTAssertTrue(viewModel.selectedStyles.contains(.rock))

        viewModel.toggleStyle(.blues)
        XCTAssertTrue(viewModel.selectedStyles.contains(.rock))
        XCTAssertTrue(viewModel.selectedStyles.contains(.blues))

        viewModel.toggleStyle(.rock)
        XCTAssertFalse(viewModel.selectedStyles.contains(.rock))
        XCTAssertTrue(viewModel.selectedStyles.contains(.blues))
    }

    // MARK: - Progress Calculation

    func testProgressCalculation() {
        let viewModel = OnboardingViewModel(storage: storage)

        // Welcome = 0/4 = 0.0
        XCTAssertEqual(viewModel.progress, 0.0, accuracy: 0.01)

        viewModel.nextStep() // Level = 1/4 = 0.25
        XCTAssertEqual(viewModel.progress, 0.25, accuracy: 0.01)

        viewModel.nextStep() // Styles = 2/4 = 0.5
        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.01)

        viewModel.toggleStyle(.pop)
        viewModel.nextStep() // Cues = 3/4 = 0.75
        XCTAssertEqual(viewModel.progress, 0.75, accuracy: 0.01)

        viewModel.nextStep() // Summary = 4/4 = 1.0
        XCTAssertEqual(viewModel.progress, 1.0, accuracy: 0.01)
    }

    // MARK: - Onboarding Completion

    func testOnboardingCompletion() {
        var completionCalled = false
        let viewModel = OnboardingViewModel(storage: storage) {
            completionCalled = true
        }

        // Navigate through all steps
        viewModel.nextStep() // Welcome -> Level
        viewModel.selectedLevel = .intermediate
        viewModel.nextStep() // Level -> Styles
        viewModel.toggleStyle(.rock)
        viewModel.toggleStyle(.blues)
        viewModel.nextStep() // Styles -> Cues
        viewModel.selectedCuePreference = .vibrationOnly
        viewModel.nextStep() // Cues -> Summary
        viewModel.nextStep() // Summary -> Complete

        XCTAssertTrue(completionCalled)

        // Verify preferences were saved
        let saved = storage.loadPreferences()
        XCTAssertEqual(saved.level, .intermediate)
        XCTAssertEqual(Set(saved.styles), Set([.rock, .blues]))
        XCTAssertEqual(saved.cuePreference, .vibrationOnly)
        XCTAssertTrue(saved.hasCompletedOnboarding)
    }

    // MARK: - Preview Blocks Generation

    func testPreviewBlocksGenerated() {
        let viewModel = OnboardingViewModel(storage: storage)

        // Navigate to summary
        viewModel.nextStep() // Welcome -> Level
        viewModel.nextStep() // Level -> Styles
        viewModel.toggleStyle(.rock)
        viewModel.nextStep() // Styles -> Cues
        viewModel.nextStep() // Cues -> Summary

        // Preview blocks should be generated
        XCTAssertFalse(viewModel.previewBlocks.isEmpty)

        // First block should be warmup
        XCTAssertEqual(viewModel.previewBlocks.first?.kind, .warmup)

        // Last block should be song (fun ending)
        XCTAssertEqual(viewModel.previewBlocks.last?.kind, .song)
    }

    func testPreviewBlockCountBasedOnLevel() {
        // Beginner level should have 6 blocks
        let beginnerVM = OnboardingViewModel(storage: storage)
        beginnerVM.selectedLevel = .beginner
        beginnerVM.nextStep() // Welcome -> Level
        beginnerVM.nextStep() // Level -> Styles
        beginnerVM.toggleStyle(.rock)
        beginnerVM.nextStep() // Styles -> Cues
        beginnerVM.nextStep() // Cues -> Summary
        XCTAssertEqual(beginnerVM.previewBlocks.count, 6)

        // Intermediate level should have 7 blocks
        let intermediateVM = OnboardingViewModel(storage: storage)
        intermediateVM.selectedLevel = .intermediate
        intermediateVM.nextStep()
        intermediateVM.nextStep()
        intermediateVM.toggleStyle(.rock)
        intermediateVM.nextStep()
        intermediateVM.nextStep()
        XCTAssertEqual(intermediateVM.previewBlocks.count, 7)

        // Advanced level should have 8 blocks
        let advancedVM = OnboardingViewModel(storage: storage)
        advancedVM.selectedLevel = .advanced
        advancedVM.nextStep()
        advancedVM.nextStep()
        advancedVM.toggleStyle(.rock)
        advancedVM.nextStep()
        advancedVM.nextStep()
        XCTAssertEqual(advancedVM.previewBlocks.count, 8)
    }
}
