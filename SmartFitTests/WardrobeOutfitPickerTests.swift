//
//  WardrobeOutfitPickerTests.swift
//  SmartFitTests
//
//  Created by Claude Code
//

import Testing
import Foundation
@testable import SmartFit

@Suite(.serialized)
struct WardrobeOutfitPickerTests {

    @Test func canSwitchBetweenAllThreeOutfits() {
        // Given: A controller with default outfit 1
        let controller = WardrobeController()

        // When: User switches through all outfits
        controller.selectedOutfit = 1
        #expect(controller.selectedOutfit == 1)

        controller.selectedOutfit = 2
        #expect(controller.selectedOutfit == 2)

        controller.selectedOutfit = 3
        #expect(controller.selectedOutfit == 3)

        // Switch back to 1
        controller.selectedOutfit = 1
        #expect(controller.selectedOutfit == 1)
    }

    @Test func selectingOutfitSavesToUserDefaults() {
        // Given: Clean UserDefaults and a controller
        UserDefaults.standard.removeObject(forKey: "savedOutfits")
        UserDefaults.standard.synchronize()

        let controller = WardrobeController()

        // When: User selects outfit 2
        controller.selectedOutfit = 2

        // Then: Outfit should be saved to UserDefaults
        let savedData = UserDefaults.standard.data(forKey: "savedOutfits")
        #expect(savedData != nil)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "savedOutfits")
    }

    @Test func eachOutfitHasIndependentState() {
        // Given: A controller with three outfits
        let controller = WardrobeController()
        controller.outfits = [
            1: ["tops": "item1"],
            2: ["bottoms": "item2"],
            3: ["shoes": "item3"]
        ]

        // When: Switching between outfits
        controller.selectedOutfit = 1
        let outfit1Items = controller.currentEquippedOutfit

        controller.selectedOutfit = 2
        let outfit2Items = controller.currentEquippedOutfit

        controller.selectedOutfit = 3
        let outfit3Items = controller.currentEquippedOutfit

        // Then: Each outfit should have its own state
        #expect(outfit1Items["tops"] == "item1")
        #expect(outfit1Items["bottoms"] == nil)

        #expect(outfit2Items["bottoms"] == "item2")
        #expect(outfit2Items["tops"] == nil)

        #expect(outfit3Items["shoes"] == "item3")
        #expect(outfit3Items["tops"] == nil)
    }
}
