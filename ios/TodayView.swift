import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Today's Practice")
                    .font(.title)
            }
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}
