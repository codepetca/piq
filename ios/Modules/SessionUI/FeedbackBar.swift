import SwiftUI

/// Presentational component for displaying feedback options after completing a block.
struct FeedbackBar: View {
    let title: String?
    let onEasy: () -> Void
    let onGood: () -> Void
    let onHard: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if let title {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 16) {
                FeedbackButton(label: "Easy", color: Color.green.opacity(0.85), textColor: .white, action: onEasy)
                FeedbackButton(label: "Good", color: Color.orange.opacity(0.85), textColor: .white, action: onGood)
                FeedbackButton(label: "Hard", color: Color.red.opacity(0.85), textColor: .white, action: onHard)
            }
        }
        .padding(.horizontal)
    }
}

/// A single feedback button with label and color.
struct FeedbackButton: View {
    let label: String
    let color: Color
    let textColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(textColor)
                .frame(width: 68, height: 68)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.25), radius: 8, x: 0, y: 4)
                )
        }
    }
}

#Preview {
    FeedbackBar(
        title: "How easy was that?",
        onEasy: { print("Easy") },
        onGood: { print("Good") },
        onHard: { print("Hard") }
    )
}
