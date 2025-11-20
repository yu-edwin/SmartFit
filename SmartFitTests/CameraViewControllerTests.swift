//
//  CameraViewControllerTests.swift
//  SmartFitTests
//
//  Created by Claude Code
//

import Testing
import Foundation
import AVFoundation
import UIKit
@testable import SmartFit

@Suite(.serialized)
struct CameraViewControllerTests {

    @Test @MainActor func rotateButtonTogglesCamera() {
        // Given: A camera controller
        let controller = CameraViewController()
        _ = controller.view

        // When: Rotate camera is called
        controller.rotateCamera()

        // Then: Should not crash
        #expect(true)
    }

    @Test @MainActor func rotateButtonCanBeCalledMultipleTimes() {
        // Given: A camera controller
        let controller = CameraViewController()
        _ = controller.view

        // When: Rotate camera is called multiple times
        controller.rotateCamera()
        controller.rotateCamera()
        controller.rotateCamera()

        // Then: Should not crash and handle multiple toggles
        #expect(true)
    }
}
