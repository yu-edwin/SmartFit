//
//  UserIDManagerTests.swift
//  SmartFitTests
//
//  Created by Edwin Yu
//

import Testing
import Foundation
@testable import SmartFit

@Suite(.serialized)
struct UserIDManagerTests {

    @Test func userIDIsGenerated() async throws {
        // Given: Clear any existing user ID
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.synchronize()

        // When: Access user ID for the first time
        let userID = UserIDManager.shared.userID

        // Then: A valid UUID should be generated
        #expect(!userID.isEmpty)
        #expect(UUID(uuidString: userID) != nil)
    }

    @Test func userIDPersistsAcrossAccesses() async throws {
        // Given: Clear any existing user ID
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.synchronize()

        // When: Access user ID multiple times
        let firstAccess = UserIDManager.shared.userID
        let secondAccess = UserIDManager.shared.userID
        let thirdAccess = UserIDManager.shared.userID

        // Then: All accesses should return the same ID
        #expect(firstAccess == secondAccess)
        #expect(secondAccess == thirdAccess)
    }

    @Test func userIDPersistsInUserDefaults() async throws {
        // Given: Clear any existing user ID
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.synchronize()

        // When: Generate a user ID
        let generatedID = UserIDManager.shared.userID

        // Then: The ID should be stored in UserDefaults
        let storedID = UserDefaults.standard.string(forKey: "userID")
        #expect(storedID != nil)
        #expect(storedID == generatedID)
    }

    @Test func userIDIsValidUUIDFormat() async throws {
        // Given: Clear any existing user ID
        UserDefaults.standard.removeObject(forKey: "userID")
        UserDefaults.standard.synchronize()

        // When: Generate a user ID
        let userID = UserIDManager.shared.userID

        // Then: It should be a valid UUID string
        let uuid = UUID(uuidString: userID)
        #expect(uuid != nil)
    }
}
