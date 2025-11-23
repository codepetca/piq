import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Practice History")
                    .font(.title)
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
}
