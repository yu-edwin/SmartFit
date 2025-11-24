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
    @StateObject private var wardrobeController = WardrobeController()

    var body: some View {
        TabView {
            WardrobeView(controller: wardrobeController)
                .tabItem {
                    Label("Wardrobe", systemImage: "hanger")
                }

            CameraView(wardrobeController: wardrobeController)
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
