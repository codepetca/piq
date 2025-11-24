import SwiftUI

/// Represents a song option for selection.
struct SongOption: Identifiable {
    let id: UUID
    let title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
}

/// Modal sheet for selecting a song from a list of options.
struct SongChoiceSheet: View {
    let options: [SongOption]
    let onSelect: (SongOption) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            List(options) { option in
                Button(action: { onSelect(option) }) {
                    HStack {
                        Text(option.title)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Choose a Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

#Preview {
    SongChoiceSheet(
        options: [
            SongOption(title: "Wish You Were Here"),
            SongOption(title: "Blackbird"),
            SongOption(title: "Stairway to Heaven")
        ],
        onSelect: { print("Selected: \($0.title)") },
        onCancel: { print("Cancelled") }
    )
}
