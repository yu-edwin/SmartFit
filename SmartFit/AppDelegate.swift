//
//  AppDelegate.swift
//  SmartFit
//
//  Created by Edwin Yu on 2025-10-09.
//

import UIKit
import SwiftUI
import Photos

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Use a UIHostingController as window root view controller.
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()

        // Seed sample photos on first launch
        seedSamplePhotosOnFirstLaunch()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /*
        Sent when the application is about to move from active to inactive state.
        This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        or when the user quits the application and it begins the transition to the background state.
        Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        Games should use this method to pause the game.
        */
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        /*
        Use this method to release shared resources, save user data, invalidate timers,
        and store enough application state information to restore your application
        to its current state in case it is terminated later.
        */
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        /*
        Called as part of the transition from the background to the active state;
        here you can undo many of the changes made on entering the background.
        */
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /*
        Restart any tasks that were paused (or not yet started) while the application was inactive.
        If the application was previously in the background, optionally refresh the user interface.
        */
    }

    // MARK: - Photo Gallery Seeding

    private func seedSamplePhotosOnFirstLaunch() {
        let hasSeededKey = "hasSeededGalleryPhotos"

        // Check if already seeded
        guard !UserDefaults.standard.bool(forKey: hasSeededKey) else {
            return
        }

        // List of sample image names from Assets.xcassets
        let sampleImageNames = ["person", "person2", "person3", "crocs", "ripped_jeans", "scarf", "sunglasses", "tshirt"]

        // Request permission and save photos
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                print("Photo library permission denied")
                return
            }

            // Save each sample image to photo library
            for imageName in sampleImageNames {
                if let image = UIImage(named: imageName) {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        if success {
                            print("Saved \(imageName) to photo library")
                        } else if let error = error {
                            print("Error saving \(imageName): \(error.localizedDescription)")
                        }
                    }
                }
            }

            // Mark as seeded
            UserDefaults.standard.set(true, forKey: hasSeededKey)
        }
    }
}
