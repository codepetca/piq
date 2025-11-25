import SwiftUI

/// A sheet view that displays a practice reference diagram with optional external link.
struct PracticeReferenceView: View {
    let reference: PracticeReference
    let onDismiss: () -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    referenceImage
                    externalLinkButton
                }
                .padding()
            }
            .navigationTitle(reference.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var referenceImage: some View {
        Image(reference.assetName)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
    }

    @ViewBuilder
    private var externalLinkButton: some View {
        if let url = reference.externalURL {
            Button {
                openURL(url)
            } label: {
                Label("Open lesson", systemImage: "arrow.up.right.square")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    PracticeReferenceView(
        reference: PracticeReference(
            id: "scale_am_pentatonic_pos1",
            title: "Am Pentatonic – pos 1",
            externalURL: URL(string: "https://example.com")
        ),
        onDismiss: {}
    )
}
