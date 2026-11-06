import SwiftUI

@main
struct OathWallpaperApp: App {
    @StateObject private var store = WallpaperStore()
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(store).preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @State private var tab: Int = 0
    var body: some View {
        TabView(selection: $tab) {
            LibraryView().tabItem { Label("壁纸", systemImage: "photo.stack") }.tag(0)
            ImportView().tabItem { Label("导入", systemImage: "square.and.arrow.down") }.tag(1)
            AboutView().tabItem { Label("我的", systemImage: "person.crop.circle") }.tag(2)
        }
        .tint(Color(red: 0.55, green: 0.48, blue: 1.0))
    }
}
