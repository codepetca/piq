import SwiftUI

/// Horizontal bar with metronome toggle and BPM controls.
/// No AVFoundation logic here - it should call into MetronomeService indirectly via callbacks.
struct MetronomeBar: View {
    let isOn: Bool
    let bpm: Int
    let onToggle: () -> Void
    let onIncreaseBPM: () -> Void
    let onDecreaseBPM: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Metronome toggle
            Button(action: onToggle) {
                Image(systemName: isOn ? "metronome.fill" : "metronome")
                    .font(.title2)
                    .foregroundColor(isOn ? .accentColor : .secondary)
            }

            Spacer()

            // BPM controls
            HStack(spacing: 12) {
                Button(action: onDecreaseBPM) {
                    Image(systemName: "minus.circle")
                        .font(.title3)
                }
                .disabled(!isOn)

                Text("\(bpm)")
                    .font(.system(.body, design: .monospaced))
                    .frame(minWidth: 44)
                    .foregroundColor(isOn ? .primary : .secondary)

                Button(action: onIncreaseBPM) {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                }
                .disabled(!isOn)
            }
            .opacity(isOn ? 1.0 : 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview("Metronome On") {
    MetronomeBar(
        isOn: true,
        bpm: 120,
        onToggle: {},
        onIncreaseBPM: {},
        onDecreaseBPM: {}
    )
    .padding()
}

#Preview("Metronome Off") {
    MetronomeBar(
        isOn: false,
        bpm: 100,
        onToggle: {},
        onIncreaseBPM: {},
        onDecreaseBPM: {}
    )
    .padding()
}
