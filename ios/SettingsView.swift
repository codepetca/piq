import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel
    @State private var showClearHistoryAlert = false
    @State private var showResetProgressAlert = false
    @State private var showClearAllAlert = false
    var onMenuTap: (() -> Void)? = nil

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            List {
                // Metronome section
                Section("Metronome") {
                    HStack {
                        Text("Default BPM")
                        Spacer()
                        Stepper("\(viewModel.defaultBPM)", value: $vm.defaultBPM, in: 40...240, step: 5)
                            .labelsHidden()
                        Text("\(viewModel.defaultBPM)")
                            .frame(width: 44)
                            .monospacedDigit()
                    }
                }

                // Feedback section
                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $vm.hapticFeedbackEnabled)
                }

                // Data section
                Section("Data") {
                    HStack {
                        Text("Practice Sessions")
                        Spacer()
                        Text("\(viewModel.totalSessions)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Practice Items")
                        Spacer()
                        Text("\(viewModel.totalItems)")
                            .foregroundColor(.secondary)
                    }

                    Button("Clear History", role: .destructive) {
                        showClearHistoryAlert = true
                    }

                    Button("Reset Progress", role: .destructive) {
                        showResetProgressAlert = true
                    }

                    Button("Clear All Data", role: .destructive) {
                        showClearAllAlert = true
                    }
                }

                // About section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onMenuTap?() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .regular))
                    }
                    .buttonStyle(.plain)
                }
            }
            .alert("Clear History?", isPresented: $showClearHistoryAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearHistory()
                }
            } message: {
                Text("This will delete all your practice session history. This cannot be undone.")
            }
            .alert("Reset Progress?", isPresented: $showResetProgressAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.resetProgress()
                }
            } message: {
                Text("This will reset all practice items to their initial state. Your scheduling progress will be lost.")
            }
            .alert("Clear All Data?", isPresented: $showClearAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllData()
                }
            } message: {
                Text("This will delete all history and reset all progress. This cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(SettingsViewModel())
}
