import SwiftUI

/// Compact metronome control with BPM inside a triangular icon plus +/- buttons.
/// No AVFoundation logic here - it should call into MetronomeService indirectly via callbacks.
struct MetronomeBar: View {
    let isOn: Bool
    let bpm: Int
    let onToggle: () -> Void
    let onAdjustBPM: (Int) -> Void
    @State private var lastDragHeight: CGFloat = 0
    @State private var lastDragWidth: CGFloat = 0

    var body: some View {
        HStack {
            ZStack(alignment: .bottom) {
                RoundedTriangle(cornerRadius: 16)
                    .fill(isOn ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.08))
                RoundedTriangle(cornerRadius: 16)
                    .stroke(isOn ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1.5)

                VStack(spacing: 2) {
                    Text("\(bpm)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(isOn ? .primary : .secondary)
                        .padding(.bottom, 6)
                    Text("bpm")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 12)
            }
            .frame(width: 96, height: 112)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let deltaHeight = value.translation.height - lastDragHeight
                        let deltaWidth = value.translation.width - lastDragWidth
                        let deltaBPM = Int((-deltaHeight) / 4) // drag up to increase, down to decrease
                        let deltaBPMHorizontal = Int((deltaWidth) / 4) // drag right to increase, left to decrease

                        let combinedDelta = deltaBPM + deltaBPMHorizontal

                        if combinedDelta != 0 {
                            onAdjustBPM(combinedDelta)
                            lastDragHeight = value.translation.height
                            lastDragWidth = value.translation.width
                        }
                    }
                    .onEnded { _ in
                        lastDragHeight = 0
                        lastDragWidth = 0
                    }
            )
            .onTapGesture {
                onToggle()
            }

        }
        .frame(maxWidth: .infinity)
        .opacity(isOn ? 1.0 : 0.8)
    }
}

#Preview("Metronome On") {
    MetronomeBar(
        isOn: true,
        bpm: 120,
        onToggle: {},
        onAdjustBPM: { _ in }
    )
    .padding()
}

#Preview("Metronome Off") {
    MetronomeBar(
        isOn: false,
        bpm: 100,
        onToggle: {},
        onAdjustBPM: { _ in }
    )
    .padding()
}

private struct RoundedTriangle: Shape {
    var cornerRadius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        // Fit an equilateral triangle inside the rect.
        let sqrt3 = CGFloat(3).squareRoot()
        let side = min(rect.width, rect.height * 2 / sqrt3)
        let height = side * sqrt3 / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let top = CGPoint(x: center.x, y: center.y - height / 2)
        let left = CGPoint(x: center.x - side / 2, y: center.y + height / 2)
        let right = CGPoint(x: center.x + side / 2, y: center.y + height / 2)

        let points = [top, right, left]
        let radius = min(cornerRadius, side / 3)

        var path = Path()
        for i in 0..<points.count {
            let current = points[i]
            let prev = points[(i + points.count - 1) % points.count]
            let next = points[(i + 1) % points.count]

            let toPrev = normalized(vector(from: current, to: prev))
            let toNext = normalized(vector(from: current, to: next))

            let start = add(current, toPrev, scaledBy: radius)
            let end = add(current, toNext, scaledBy: radius)

            if i == 0 {
                path.move(to: start)
            } else {
                path.addLine(to: start)
            }

            path.addQuadCurve(to: end, control: current)
        }

        path.closeSubpath()
        return path
    }

    // MARK: - Geometry helpers

    private func vector(from: CGPoint, to: CGPoint) -> CGVector {
        CGVector(dx: to.x - from.x, dy: to.y - from.y)
    }

    private func normalized(_ vector: CGVector) -> CGVector {
        let length = hypot(vector.dx, vector.dy)
        guard length > 0 else { return .zero }
        return CGVector(dx: vector.dx / length, dy: vector.dy / length)
    }

    private func add(_ point: CGPoint, _ vector: CGVector, scaledBy scale: CGFloat) -> CGPoint {
        CGPoint(x: point.x + vector.dx * scale, y: point.y + vector.dy * scale)
    }
}
