//
//  CameraUITests.swift
//  SmartFitUITests
//
//  Created by Claude Code
//

import XCTest

final class CameraUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testCameraTabExists() throws {
        // Given: App is launched
        // When: Looking for camera tab
        let cameraTab = app.tabBars.buttons["Camera"]

        // Then: Camera tab should exist
        XCTAssertTrue(cameraTab.exists)
    }

    @MainActor
    func testCameraTabIsAccessible() throws {
        // Given: App is launched
        // When: Tapping camera tab
        let cameraTab = app.tabBars.buttons["Camera"]
        cameraTab.tap()

        // Then: Camera tab should be selected
        XCTAssertTrue(cameraTab.isSelected)
    }

    @MainActor
    func testCaptureButtonExists() throws {
        // Given: App is on camera tab
        let cameraTab = app.tabBars.buttons["Camera"]
        cameraTab.tap()

        // When: Looking for capture button
        let captureButton = app.buttons["capturePhotoButton"]

        // Then: Capture button should exist
        XCTAssertTrue(captureButton.waitForExistence(timeout: 2))
    }

    @MainActor
    func testRotateCameraButtonExists() throws {
        // Given: App is on camera tab
        let cameraTab = app.tabBars.buttons["Camera"]
        cameraTab.tap()

        // When: Looking for rotate button
        let rotateButton = app.buttons["rotateCameraButton"]

        // Then: Rotate button should exist
        XCTAssertTrue(rotateButton.waitForExistence(timeout: 2))
    }

    @MainActor
    func testRotateCameraButtonIsTappable() throws {
        // Given: App is on camera tab
        let cameraTab = app.tabBars.buttons["Camera"]
        cameraTab.tap()

        // When: Tapping rotate camera button
        let rotateButton = app.buttons["rotateCameraButton"]
        XCTAssertTrue(rotateButton.waitForExistence(timeout: 2))
        rotateButton.tap()

        // Then: Should not crash (actual camera switching can't be verified in UI tests)
        XCTAssertTrue(rotateButton.exists)
    }

    // Note: The following tests require camera capture to work
    // They may not work reliably in simulator - run on device if they fail

    @MainActor
    func testOutfitSwitchingInPhotoForm() throws {
        // Given: App is on camera tab
        let cameraTab = app.tabBars.buttons["Camera"]
        cameraTab.tap()

        // Wait for wardrobe to load
        sleep(2)

        // When: Capturing a photo
        let captureButton = app.buttons["capturePhotoButton"]
        XCTAssertTrue(captureButton.waitForExistence(timeout: 2))
        captureButton.tap()

        // Wait for photo form to appear
        let outfitPicker = app.segmentedControls["outfitPicker"]
        guard outfitPicker.waitForExistence(timeout: 5) else {
            XCTFail("Photo form did not appear - may need to run on physical device with camera")
            return
        }

        // Then: Should be able to switch outfits
        // When: Tapping Outfit 2 in the picker
        outfitPicker.buttons["Outfit 2"].tap()

        // Then: Picker should show Outfit 2 selected
        // When: Tapping Outfit 3 in the picker
        outfitPicker.buttons["Outfit 3"].tap()

        // Then: Should not crash
        XCTAssertTrue(outfitPicker.exists)
    }

    @MainActor
    func testGenerateButtonInPhotoForm() throws {
        // Given: App is on camera tab
        let cameraTab = app.tabBars.buttons["Camera"]
        cameraTab.tap()

        sleep(2)

        // When: Capturing a photo
        let captureButton = app.buttons["capturePhotoButton"]
        captureButton.tap()

        let generateButton = app.buttons["generateButton"]
        guard generateButton.waitForExistence(timeout: 5) else {
            XCTFail("Photo form did not appear - may need to run on physical device with camera")
            return
        }

        // When: Tapping generate button
        generateButton.tap()

        // Then: Should not crash (actual behavior depends on implementation)
        XCTAssertTrue(generateButton.exists)
    }

    @MainActor
    func testCancelButtonClosesPhotoForm() throws {
        // Given: App is on camera tab
        let cameraTab = app.tabBars.buttons["Camera"]
        cameraTab.tap()

        sleep(2)

        // When: Capturing a photo
        let captureButton = app.buttons["capturePhotoButton"]
        captureButton.tap()

        let cancelButton = app.buttons["cancelButton"]
        guard cancelButton.waitForExistence(timeout: 5) else {
            XCTFail("Photo form did not appear - may need to run on physical device with camera")
            return
        }

        // When: Tapping cancel button
        cancelButton.tap()

        // Then: Photo form should be dismissed
        let capturedPhoto = app.images["capturedPhoto"]
        XCTAssertFalse(capturedPhoto.waitForExistence(timeout: 1))
    }
}
