import SwiftUI
import shared

/// Root view — mirrors the Android bottom-navigation structure.
/// Replace tab bodies with full SwiftUI screens as they are built out.
struct ContentView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ChaptersView()
                .tabItem {
                    Label("Gita", systemImage: "book.fill")
                }
                .tag(1)

            AiraChatView()
                .tabItem {
                    Label("Aira", systemImage: "sparkles")
                }
                .tag(2)

            BookmarksView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(4)
        }
        .tint(.orange)   // Saffron brand accent
    }
}

// ── Placeholder screens ── replace with full SwiftUI implementations ──────────

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Namaste 🙏")
                    .font(.largeTitle.bold())
                Text("Daily verse will appear here once the data layer is wired up.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Gita Nexus")
        }
    }
}

struct ChaptersView: View {
    var body: some View {
        NavigationStack {
            Text("Bhagavad Gita chapters")
                .navigationTitle("Bhagavad Gita")
        }
    }
}

struct AiraChatView: View {
    var body: some View {
        NavigationStack {
            Text("Aira AI chat")
                .navigationTitle("Aira")
        }
    }
}

struct BookmarksView: View {
    var body: some View {
        NavigationStack {
            Text("Saved verses")
                .navigationTitle("Saved")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            Text("Profile")
                .navigationTitle("Profile")
        }
    }
}
