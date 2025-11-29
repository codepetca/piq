import SwiftUI

/// Welcome step view for onboarding.
struct WelcomeStepView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon / logo area
            Image(systemName: "guitars")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("piq")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Guitar practice")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onNext) {
                Text("Get started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Preview

#Preview("Welcome") {
    WelcomeStepView { }
}
