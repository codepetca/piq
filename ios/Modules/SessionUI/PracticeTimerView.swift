import SwiftUI

/// Presentational component for displaying practice timer with progress rings.
/// No timing logic belongs here - this is purely presentational.
struct PracticeTimerView: View {
    let title: String
    let detail: String
    let timeText: String
    let blockProgress: Double      // 0.0–1.0
    let isPaused: Bool
    let onTogglePause: () -> Void
    let onAdjustTime: (Int) -> Void
    let namespace: Namespace.ID?
    let titleHeroID: String?
    let detailHeroID: String?
    @State private var lastDragHeight: CGFloat = 0
    @State private var lastDragWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: 24) {
            // Block info
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                    .matchedGeometryEffectIfPossible(id: titleHeroID, in: namespace)
                if !detail.isEmpty {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity)
                        .matchedGeometryEffectIfPossible(id: detailHeroID, in: namespace)
                }
            }

            // Timer with concentric progress rings
            ZStack {
                // Outer ring - block progress (current block time remaining)
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: blockProgress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                // Timer text
                VStack(spacing: 4) {
                    Text(timeText)
                        .font(.system(size: 48, weight: .light, design: .monospaced))
                        .contentTransition(.numericText())

                    if isPaused {
                        Text("PAUSED")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 240, height: 240)
            .padding(.horizontal, 32) // expand hit area for swipes
            .contentShape(Rectangle())
            .onTapGesture {
                onTogglePause()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let deltaHeight = value.translation.height - lastDragHeight
                        let deltaWidth = value.translation.width - lastDragWidth
                        let secondsDeltaVertical = Int((-deltaHeight) / 5) // Drag up to add, down to reduce
                        let secondsDeltaHorizontal = Int((deltaWidth) / 5) // Drag right to add, left to reduce

                        let combined = secondsDeltaVertical + secondsDeltaHorizontal

                        if combined != 0 {
                            onAdjustTime(combined)
                            lastDragHeight = value.translation.height
                            lastDragWidth = value.translation.width
                        }
                    }
                    .onEnded { _ in
                        lastDragHeight = 0
                        lastDragWidth = 0
                    }
            )
        }
    }
}

#Preview("In Progress") {
    PracticeTimerView(
        title: "Am Pentatonic Scale",
        detail: "Position 1",
        timeText: "08:32",
        blockProgress: 0.35,
        isPaused: false,
        onTogglePause: {},
        onAdjustTime: { _ in },
        namespace: nil,
        titleHeroID: nil,
        detailHeroID: nil
    )
}

#Preview("Paused") {
    PracticeTimerView(
        title: "Wish You Were Here",
        detail: "",
        timeText: "05:15",
        blockProgress: 0.5,
        isPaused: true,
        onTogglePause: {},
        onAdjustTime: { _ in },
        namespace: nil,
        titleHeroID: nil,
        detailHeroID: nil
    )
}
