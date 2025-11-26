import SwiftUI

/// UI extension for feedback colors.
extension PracticeBlockFeedback {
    /// Color associated with this feedback type.
    var color: Color {
        switch self {
        case .easy:
            return .green
        case .good:
            return .blue
        case .hard:
            return .orange
        }
    }
}
