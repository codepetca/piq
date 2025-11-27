import SwiftUI

/// Preview modal shown before starting each practice block.
struct BlockPreviewView: View {
    let block: PracticeBlock
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Kind badge
            Text(block.kind.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor)
                .cornerRadius(8)

            // Title + Detail
            VStack(spacing: 8) {
                Text(block.title)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)

                if !block.detail.isEmpty {
                    Text(block.detail)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)

            // Focus cue (primary instruction)
            if let focusCue = block.focusCue {
                Text(focusCue)
                    .font(.title3)
                    .italic()
                    .foregroundStyle(.tint)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            // Key badge
            if let key = block.key {
                HStack(spacing: 6) {
                    Image(systemName: "music.note")
                        .font(.caption)
                    Text(key)
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }

            Spacer()

            // Tap instruction
            VStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundStyle(.tertiary)

                Text("Tap to start")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .contentShape(Rectangle())  // Make entire area tappable
        .onTapGesture {
            onStart()
        }
    }
}

#Preview("Full Block") {
    BlockPreviewView(
        block: PracticeBlock(
            kind: .warmup,
            title: "Chromatic Warm-Up",
            detail: "Position 1-4",
            key: "Am",
            focusCue: "Super slow, perfect tone"
        ),
        onStart: {}
    )
}

#Preview("Minimal Block") {
    BlockPreviewView(
        block: PracticeBlock(
            kind: .song,
            title: "Wonderwall",
            detail: "Verse section"
        ),
        onStart: {}
    )
}

#Preview("No Detail") {
    BlockPreviewView(
        block: PracticeBlock(
            kind: .solo,
            title: "Blues Improv",
            key: "E"
        ),
        onStart: {}
    )
}
