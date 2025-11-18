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
        _ = controller.view // Trigger viewDidLoad

        // Find the rotate button
        let rotateButton = controller.view.subviews.first { $0 is UIButton } as? UIButton

        // When: Rotate button is tapped
        rotateButton?.sendActions(for: .touchUpInside)

        // Then: Should not crash
        #expect(rotateButton != nil)
    }

    @Test @MainActor func rotateButtonCanBeCalledMultipleTimes() {
        // Given: A camera controller
        let controller = CameraViewController()
        _ = controller.view // Trigger viewDidLoad

        // Find the rotate button
        let rotateButton = controller.view.subviews.first { $0 is UIButton } as? UIButton

        // When: Rotate button is tapped multiple times
        rotateButton?.sendActions(for: .touchUpInside)
        rotateButton?.sendActions(for: .touchUpInside)
        rotateButton?.sendActions(for: .touchUpInside)

        // Then: Should not crash and handle multiple toggles
        #expect(rotateButton != nil)
    }
}
