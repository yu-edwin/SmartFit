import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @StateObject private var authController = AuthenticationController()

    var body: some View {
        if authController.isAuthenticated() {
            MainTabView()
                .environmentObject(authController)
        } else {
            AuthView(authController: authController)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            WardrobeView()
                .tabItem {
                    Label("Wardrobe", systemImage: "hanger")
                }

            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
