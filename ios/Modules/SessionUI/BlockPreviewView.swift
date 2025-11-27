import SwiftUI

/// Displays a preview/transition screen before each practice block.
/// Shows block information with a countdown and tap-to-start functionality.
struct BlockPreviewView: View {
    let blockKind: String
    let title: String
    let detail: String?
    let focusCue: String?
    let instructions: [String]
    let secondsRemaining: Int
    let onTapToStart: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Block kind label
            Text(blockKind.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .tracking(1.5)
            
            // Block title
            VStack(spacing: 8) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if let detail = detail, !detail.isEmpty {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // Focus cue and instructions
            if let focusCue = focusCue, !focusCue.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    // Focus cue
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.tint)
                        
                        Text(focusCue)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.tint)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Instructions
                    if !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(instructions.indices, id: \.self) { index in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 4))
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 6)
                                    
                                    Text(instructions[index])
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.leading, 18)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Tap to start / countdown
            Button(action: onTapToStart) {
                VStack(spacing: 8) {
                    Text("Tap to start")
                        .font(.headline)
                        .foregroundStyle(.tint)
                    
                    Text("\(secondsRemaining)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.tint)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("With Instructions") {
    BlockPreviewView(
        blockKind: "Warm-Up",
        title: "Chromatic Warm-Up",
        detail: nil,
        focusCue: "Super slow, perfect tone",
        instructions: [
            "1–2–3–4 pattern, one finger per fret",
            "Use strict alternate picking",
            "Check every note rings clearly"
        ],
        secondsRemaining: 4,
        onTapToStart: {}
    )
}

#Preview("Without Instructions") {
    BlockPreviewView(
        blockKind: "Solo",
        title: "Am Pentatonic Improv",
        detail: "Position 1",
        focusCue: "Play what you feel",
        instructions: [],
        secondsRemaining: 2,
        onTapToStart: {}
    )
}

#Preview("Minimal") {
    BlockPreviewView(
        blockKind: "Song",
        title: "Wonderwall",
        detail: "Verse",
        focusCue: nil,
        instructions: [],
        secondsRemaining: 3,
        onTapToStart: {}
    )
}
