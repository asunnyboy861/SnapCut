import SwiftUI

struct MainTabView: View {
    @StateObject private var appState = AppState.shared

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            CreateView()
                .tabItem {
                    Image(systemName: "wand.and.stars")
                    Text("Create")
                }
                .tag(0)

            TemplateGalleryView()
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
                    Text("Templates")
                }
                .tag(1)

            MyShortcutsView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("My Cuts")
                }
                .tag(2)

            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .tint(Color(hex: "8B5CF6"))
    }
}

#Preview {
    MainTabView()
}
