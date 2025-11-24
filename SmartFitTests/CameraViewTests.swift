//
//  CameraViewTests.swift
//  SmartFitTests
//
//  Created by Claude Code
//

import Testing
import Foundation
import SwiftUI
@testable import SmartFit

@Suite(.serialized)
struct CameraViewTests {

    @Test func identifiableImageCreatesUniqueIds() {
        // Given: Two IdentifiableImage instances with the same image
        let testImage = UIImage()
        let image1 = IdentifiableImage(image: testImage)
        let image2 = IdentifiableImage(image: testImage)

        // Then: They should have different IDs
        #expect(image1.id != image2.id)
    }

    @Test func identifiableImageStoresImage() {
        // Given: A test image
        let testImage = UIImage()

        // When: Creating an IdentifiableImage
        let identifiableImage = IdentifiableImage(image: testImage)

        // Then: It should store the image
        #expect(identifiableImage.image == testImage)
    }

    @Test @MainActor func cameraViewInitializesWithController() {
        // Given: A wardrobe controller
        let wardrobeController = WardrobeController()

        // When: Creating a CameraView
        let cameraView = CameraView(wardrobeController: wardrobeController)

        // Then: View should be created without crashing
        #expect(cameraView.wardrobeController === wardrobeController)
    }
}
