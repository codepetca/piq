import SwiftUI

struct RootView: View {
    @State private var selection: SidebarItem = .today
    @State private var isSidebarVisible = false

    var body: some View {
        ZStack(alignment: .leading) {
            contentView
                .disabled(isSidebarVisible)
                .animation(.easeInOut(duration: 0.18), value: isSidebarVisible)

            if isSidebarVisible {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            isSidebarVisible = false
                        }
                    }
                    .transition(.opacity)
            }

            if isSidebarVisible {
                SidebarMenu(
                    selected: selection,
                    onSelect: { item in
                        selection = item
                        withAnimation(.easeInOut(duration: 0.18)) {
                            isSidebarVisible = false
                        }
                    }
                )
                .transition(.move(edge: .leading))
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentView: some View {
        switch selection {
        case .today:
            TodayView(onMenuTap: toggleSidebar)
        case .profile:
            ProfilePlaceholderView(onMenuTap: toggleSidebar)
        case .history:
            HistoryView(onMenuTap: toggleSidebar)
        case .settings:
            SettingsView(onMenuTap: toggleSidebar)
        }
    }

    private func toggleSidebar() {
        withAnimation(.easeInOut(duration: 0.18)) {
            isSidebarVisible.toggle()
        }
    }
}

// MARK: - Sidebar Menu

private struct SidebarMenu: View {
    let selected: SidebarItem
    let onSelect: (SidebarItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("piq")
                .font(.title2.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.top, 20)

            ForEach(SidebarItem.allCases) { item in
                Button {
                    onSelect(item)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.iconName)
                            .frame(width: 22)
                        Text(item.title)
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        item == selected
                        ? Color.accentColor.opacity(0.12)
                        : Color.clear
                    )
                    .foregroundColor(item == selected ? .accentColor : .primary)
                    .cornerRadius(12)
                }
            }

            Spacer()
        }
        .frame(maxWidth: 280, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.regularMaterial)
        .ignoresSafeArea()
    }
}

// MARK: - Sidebar Item

private enum SidebarItem: String, CaseIterable, Identifiable {
    case today
    case profile
    case history
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            return "Today"
        case .profile:
            return "Profile"
        case .history:
            return "History"
        case .settings:
            return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .today:
            return "guitars"
        case .profile:
            return "person.crop.circle"
        case .history:
            return "clock.arrow.circlepath"
        case .settings:
            return "gearshape"
        }
    }
}

// MARK: - Profile Placeholder

private struct ProfilePlaceholderView: View {
    var onMenuTap: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("Profile")
                    .font(.title3)
                    .fontWeight(.medium)

                Text("Profile details coming soon.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onMenuTap?() }) {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }
}

#Preview {
    RootView()
}
