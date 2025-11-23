//
//  PhotoFormViewTests.swift
//  SmartFitTests
//
//  Created by Claude Code
//

import Testing
import Foundation
import SwiftUI
@testable import SmartFit

@Suite(.serialized)
struct PhotoFormViewTests {

    @Test @MainActor func photoFormViewInitializesWithImage() {
        // Given: A test image and controller
        let testImage = UIImage()
        let controller = WardrobeController()
        let isPresented = Binding.constant(true)

        // When: Creating a PhotoFormView
        let view = PhotoFormView(
            image: testImage,
            isPresented: isPresented,
            wardrobeController: controller
        )

        // Then: View should be created without crashing
        #expect(view.image == testImage)
    }

    @Test @MainActor func equippedItemsReturnsEmptyWhenNoItemsEquipped() {
        // Given: A controller with empty outfit
        let testImage = UIImage()
        let controller = WardrobeController()
        controller.outfits[1] = [:]
        let isPresented = Binding.constant(true)

        // When: Creating view and checking equipped items
        let view = PhotoFormView(
            image: testImage,
            isPresented: isPresented,
            wardrobeController: controller
        )

        // Then: Should return empty array
        #expect(view.equippedItems.isEmpty)
    }

    @Test @MainActor func equippedItemsReturnsItemsWhenOutfitHasItems() {
        // Given: A controller with items in wardrobe and outfit
        let testImage = UIImage()
        let controller = WardrobeController()

        // Mock wardrobe item
        let mockItem = WardrobeItem(
            id: "test-123",
            userId: "user-1",
            category: "tops",
            name: "Test Shirt",
            brand: nil,
            image_data: nil,
            price: nil,
            color: "Blue",
            size: "M",
            material: nil,
            item_url: nil
        )
        controller.model.items = [mockItem]
        controller.outfits[1] = ["tops": "test-123"]

        let isPresented = Binding.constant(true)

        // When: Creating view and checking equipped items
        let view = PhotoFormView(
            image: testImage,
            isPresented: isPresented,
            wardrobeController: controller
        )

        // Then: Should return the equipped item
        #expect(view.equippedItems.count == 1)
        #expect(view.equippedItems.first?.id == "test-123")
    }

    @Test @MainActor func equippedItemsFiltersOutInvalidItemIds() {
        // Given: A controller with outfit containing non-existent item ID
        let testImage = UIImage()
        let controller = WardrobeController()

        let validItem = WardrobeItem(
            id: "valid-id",
            userId: "user-1",
            category: "tops",
            name: "Valid Shirt",
            brand: nil,
            image_data: nil,
            price: nil,
            color: "Blue",
            size: "M",
            material: nil,
            item_url: nil
        )

        controller.model.items = [validItem]
        controller.outfits[1] = [
            "tops": "valid-id",
            "bottoms": "non-existent-id"
        ]

        let isPresented = Binding.constant(true)

        // When: Creating view
        let view = PhotoFormView(
            image: testImage,
            isPresented: isPresented,
            wardrobeController: controller
        )

        // Then: Should only return valid item
        #expect(view.equippedItems.count == 1)
        #expect(view.equippedItems.first?.id == "valid-id")
    }
}
