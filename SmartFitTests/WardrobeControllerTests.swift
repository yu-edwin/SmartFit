//
//  WardrobeControllerTests.swift
//  SmartFitTests
//
//  Created by Claude Code
//

import Testing
import Foundation
@testable import SmartFit

@Suite(.serialized)
struct WardrobeControllerTests {

    // MARK: - EquipItem Tests

    @Test func equipItemAddsItemToOutfit() async throws {
        // Given: A controller with an empty outfit
        let controller = WardrobeController()
        controller.selectedOutfit = 1

        // When: Equipping an item
        controller.equipItem(itemId: "item-123", category: "tops")

        // Then: The item should be equipped in the outfit
        #expect(controller.outfits[1]?["tops"] == "item-123")
    }

    @Test func equipItemThenChangeItem() async throws {
        // Given: A controller with an equipped item
        let controller = WardrobeController()
        controller.selectedOutfit = 1
        controller.equipItem(itemId: "item-123", category: "tops")

        // When: Equipping a different item in the same category
        controller.equipItem(itemId: "item-456", category: "tops")

        // Then: The new item should replace the old one
        #expect(controller.outfits[1]?["tops"] == "item-456")
    }

    @Test func equipItemThenUnequip() async throws {
        // Given: A controller with an equipped item
        let controller = WardrobeController()
        controller.selectedOutfit = 1
        controller.equipItem(itemId: "item-123", category: "tops")

        // Verify it's equipped
        #expect(controller.outfits[1]?["tops"] == "item-123")

        // When: Tapping the same item again to unequip
        controller.equipItem(itemId: "item-123", category: "tops")

        // Then: The item should be unequipped (nil)
        #expect(controller.outfits[1]?["tops"] == nil)
    }
}
