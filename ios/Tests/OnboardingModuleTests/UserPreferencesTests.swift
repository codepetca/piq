import XCTest
@testable import piq

final class UserPreferencesTests: XCTestCase {

    // MARK: - Default Values

    func testDefaultPreferences() {
        let preferences = UserPreferences.default

        XCTAssertEqual(preferences.level, .beginner)
        XCTAssertTrue(preferences.styles.isEmpty)
        XCTAssertEqual(preferences.cuePreference, .soundAndVibration)
        XCTAssertFalse(preferences.hasCompletedOnboarding)
    }

    // MARK: - Cue Preference Behavior

    func testSoundAndVibrationCuePreference() {
        let cue = CuePreference.soundAndVibration

        XCTAssertTrue(cue.metronomeEnabled)
        XCTAssertTrue(cue.hapticEnabled)
    }

    func testVibrationOnlyCuePreference() {
        let cue = CuePreference.vibrationOnly

        XCTAssertFalse(cue.metronomeEnabled)
        XCTAssertTrue(cue.hapticEnabled)
    }

    func testSilentCuePreference() {
        let cue = CuePreference.silent

        XCTAssertFalse(cue.metronomeEnabled)
        XCTAssertFalse(cue.hapticEnabled)
    }

    // MARK: - Display Names

    func testUserLevelDisplayNames() {
        XCTAssertEqual(UserLevel.beginner.displayName, "Beginner+")
        XCTAssertEqual(UserLevel.intermediate.displayName, "Intermediate")
        XCTAssertEqual(UserLevel.advanced.displayName, "Advanced")
    }

    func testMusicStyleDisplayNames() {
        XCTAssertEqual(MusicStyle.rock.displayName, "Rock")
        XCTAssertEqual(MusicStyle.pop.displayName, "Pop")
        XCTAssertEqual(MusicStyle.blues.displayName, "Blues")
        XCTAssertEqual(MusicStyle.rnb.displayName, "R&B")
        XCTAssertEqual(MusicStyle.worship.displayName, "Worship")
    }

    func testCuePreferenceDisplayNames() {
        XCTAssertEqual(CuePreference.soundAndVibration.displayName, "Sound + Vibration")
        XCTAssertEqual(CuePreference.vibrationOnly.displayName, "Vibration only")
        XCTAssertEqual(CuePreference.silent.displayName, "Silent")
    }

    // MARK: - Codable

    func testPreferencesEncodeDecode() throws {
        let original = UserPreferences(
            level: .intermediate,
            styles: [.rock, .blues],
            cuePreference: .vibrationOnly,
            hasCompletedOnboarding: true
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(UserPreferences.self, from: data)

        XCTAssertEqual(decoded.level, .intermediate)
        XCTAssertEqual(Set(decoded.styles), Set([.rock, .blues]))
        XCTAssertEqual(decoded.cuePreference, .vibrationOnly)
        XCTAssertTrue(decoded.hasCompletedOnboarding)
    }
}
