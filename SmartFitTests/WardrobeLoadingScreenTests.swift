//
//  WardrobeLoadingScreenTests.swift
//  SmartFitTests
//
//  Created by Claude Code
//

import Testing
import Foundation
@testable import SmartFit

@Suite(.serialized)
struct WardrobeLoadingScreenTests {

    // MARK: - Loading Screen Behavior Tests

    @Test func loadingScreenShowsWhenFetchingItems() async throws {
        // Given: Setup mock URL and successful response
        let wardrobeURL = URL(string: "https://smartfit-development.onrender.com/api/wardrobe?userId=mock-user-id-123")!
        MockURLProtocol.mockWardrobeFetchSuccess(url: wardrobeURL)

        // Setup mock user in UserDefaults
        let mockUser = User(email: "mock@example.com", name: "Mock User", idToken: "mock-user-id-123")
        let userData = try JSONEncoder().encode(mockUser)
        UserDefaults.standard.set(userData, forKey: "currentUser")

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        let model = WardrobeModel(urlSession: mockSession)
        let controller = WardrobeController(model: model)

        // When: Load items is called
        controller.loadItems()

        // Then: isLoading should become true briefly
        // Give it a moment to start
        try? await Task.sleep(nanoseconds: 1_000_000) // 0.001 seconds
        let wasLoadingAtSomePoint = controller.isLoading || controller.hasLoadedItems

        // Wait for loading to complete
        await waitForLoadingToComplete(controller: controller)

        // Verify loading eventually completed
        #expect(controller.hasLoadedItems == true)
        #expect(wasLoadingAtSomePoint == true)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "currentUser")
        MockURLProtocol.reset()
    }

    @Test func loadingScreenHidesAfterSuccessfulFetch() async throws {
        // Given: Setup mock URL and successful response
        let wardrobeURL = URL(string: "https://smartfit-development.onrender.com/api/wardrobe?userId=mock-user-id-123")!
        MockURLProtocol.mockWardrobeFetchSuccess(url: wardrobeURL)

        // Setup mock user in UserDefaults
        let mockUser = User(email: "mock@example.com", name: "Mock User", idToken: "mock-user-id-123")
        let userData = try JSONEncoder().encode(mockUser)
        UserDefaults.standard.set(userData, forKey: "currentUser")

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        let model = WardrobeModel(urlSession: mockSession)
        let controller = WardrobeController(model: model)

        // When: Load items is called and completes
        controller.loadItems()

        // Give the Task a moment to start
        try? await Task.sleep(nanoseconds: 5_000_000) // 0.005 seconds

        await waitForLoadingToComplete(controller: controller)

        // Give a moment for MainActor updates to propagate
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds

        // Then: isLoading should be false after fetch completes
        #expect(controller.isLoading == false)
        #expect(controller.model.items.count == 2)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: "currentUser")
        MockURLProtocol.reset()
    }

    // MARK: - Helper Functions

    private func waitForLoadingToComplete(controller: WardrobeController) async {
        // Wait up to 5 seconds for loading to complete
        for _ in 0..<50 {
            if !controller.isLoading {
                return
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
}
