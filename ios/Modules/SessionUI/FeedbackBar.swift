import SwiftUI

/// Presentational component for displaying feedback options after completing a block.
struct FeedbackBar: View {
    let onEasy: () -> Void
    let onGood: () -> Void
    let onHard: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("How was that?")
                .font(.title2)

            HStack(spacing: 16) {
                FeedbackButton(label: "Easy", color: .green, action: onEasy)
                FeedbackButton(label: "Good", color: .blue, action: onGood)
                FeedbackButton(label: "Hard", color: .orange, action: onHard)
            }
        }
        .padding(.horizontal)
    }
}

/// A single feedback button with label and color.
struct FeedbackButton: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .cornerRadius(12)
        }
    }
}

#Preview {
    FeedbackBar(
        onEasy: { print("Easy") },
        onGood: { print("Good") },
        onHard: { print("Hard") }
    )
}
