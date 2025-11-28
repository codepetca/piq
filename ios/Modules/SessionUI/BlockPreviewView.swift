import SwiftUI

/// Displays a preview/transition screen before each practice block.
/// Shows block information with a countdown and tap-to-start functionality.
struct BlockPreviewView: View {
    let title: String
    let detail: String?
    let focusCue: String?
    let instructions: [String]
    let secondsRemaining: Int
    let onTapToStart: () -> Void
    let namespace: Namespace.ID?
    let heroID: String?
    let titleHeroID: String?
    let detailHeroID: String?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Block title
            VStack(spacing: 8) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .matchedGeometryEffectIfPossible(id: titleHeroID, in: namespace)
                
                if let detail = detail, !detail.isEmpty {
                    Text(detail)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .matchedGeometryEffectIfPossible(id: detailHeroID, in: namespace)
                }
            }
            .padding(.horizontal)
            
            BlockInstructionsHeroCard(
                instructions: instructions,
                focusCue: focusCue,
                namespace: namespace,
                heroID: heroID
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Countdown inside circle
            let previewProgress = min(max(Double(secondsRemaining) / 10.0, 0), 1)
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: previewProgress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(secondsRemaining)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.tint)
                    .contentTransition(.numericText())
            }
            .frame(width: 200, height: 200)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            onTapToStart()
        }
    }
}

#Preview("With Instructions") {
    BlockPreviewView(
        title: "Chromatic Warm-Up",
        detail: nil,
        focusCue: "Super slow, perfect tone",
        instructions: [
            "1–2–3–4 pattern, one finger per fret",
            "Use strict alternate picking",
            "Check every note rings clearly"
        ],
        secondsRemaining: 10,
        onTapToStart: {},
        namespace: nil,
        heroID: "preview-1",
        titleHeroID: "title-1",
        detailHeroID: "detail-1"
    )
}

#Preview("Without Instructions") {
    BlockPreviewView(
        title: "Am Pentatonic Improv",
        detail: "Position 1",
        focusCue: "Play what you feel",
        instructions: [],
        secondsRemaining: 10,
        onTapToStart: {},
        namespace: nil,
        heroID: "preview-2",
        titleHeroID: "title-2",
        detailHeroID: "detail-2"
    )
}

#Preview("Minimal") {
    BlockPreviewView(
        title: "Wonderwall",
        detail: "Verse",
        focusCue: nil,
        instructions: [],
        secondsRemaining: 10,
        onTapToStart: {},
        namespace: nil,
        heroID: "preview-3",
        titleHeroID: "title-3",
        detailHeroID: "detail-3"
    )
}

/// Shared instructions/focus view wrapped in a light card for the hero-style transition into the session screen.
struct BlockInstructionsHeroCard: View {
    let instructions: [String]
    let focusCue: String?
    let namespace: Namespace.ID?
    let heroID: String?
    
    var body: some View {
        Group {
            if hasContent {
                VStack(alignment: .leading, spacing: 12) {
                    if !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(instructions.indices, id: \.self) { index in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 5))
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 7)
                                    
                                    Text(instructions[index])
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    
                    if let focusCue = focusCue, !focusCue.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.tint)
                            
                            Text(focusCue)
                                .font(.body)
                                .italic()
                                .foregroundStyle(.tint)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .matchedGeometryEffectIfPossible(id: heroID, in: namespace)
            }
        }
    }
    
    private var hasContent: Bool {
        !instructions.isEmpty || (focusCue?.isEmpty == false)
    }
}

extension View {
    @ViewBuilder
    func matchedGeometryEffectIfPossible(id: String?, in namespace: Namespace.ID?) -> some View {
        if let namespace, let id {
            self.matchedGeometryEffect(id: id, in: namespace, properties: .frame, anchor: .center)
        } else {
            self
        }
    }
}
