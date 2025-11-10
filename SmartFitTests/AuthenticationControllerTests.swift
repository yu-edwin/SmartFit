//
//  AuthenticationControllerTests.swift
//  SmartFitTests
//
//  Created by Edwin Yu
//

import Testing
import Foundation
@testable import SmartFit

@Suite(.serialized)
struct AuthenticationControllerTests {

    // MARK: - Login Tests

    @Test func loginSuccessfullyAuthenticatesUser() async throws {
        // Given: Setup mock URL and response
        let loginURL = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/login")!
        MockURLProtocol.mockLoginSuccess(url: loginURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController(urlSession: mockSession)
        let expectation = Expectation()

        // When: Login with valid credentials
        authController.login(email: "mock@example.com", password: "password123") { success, error in
            // Then: Login should succeed
            #expect(success == true)
            #expect(error == nil)
            #expect(authController.currentUser != nil)
            #expect(authController.currentUser?.email == "mock@example.com")
            expectation.fulfill()
        }

        await expectation.fulfillment()
        MockURLProtocol.reset()
    }

    @Test func loginPersistsUserIDToStorage() async throws {
        // Given: Setup mock URL and response
        let loginURL = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/login")!
        MockURLProtocol.mockLoginSuccess(url: loginURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController(urlSession: mockSession)
        let expectation = Expectation()

        // When: Login with valid credentials
        authController.login(email: "mock@example.com", password: "password123") { success, error in
            // Then: User ID should be persisted to storage
            #expect(success == true)

            let storedData = UserDefaults.standard.data(forKey: "currentUser")
            #expect(storedData != nil)

            if let storedUser = try? JSONDecoder().decode(User.self, from: storedData!) {
                #expect(storedUser.idToken == "mock-user-id-123")
                #expect(storedUser.email == "mock@example.com")
                #expect(storedUser.name == "Mock User")
            }

            expectation.fulfill()
        }

        await expectation.fulfillment()
        MockURLProtocol.reset()
    }

    @Test func loginWithInvalidCredentialsFails() async throws {
        // Given: Setup mock URL and failure response
        let loginURL = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/login")!
        MockURLProtocol.mockLoginFailure(url: loginURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController(urlSession: mockSession)
        let expectation = Expectation()

        // When: Login with invalid credentials
        authController.login(email: "wrong@example.com", password: "wrongpass") { success, error in
            // Then: Login should fail
            #expect(success == false)
            #expect(error != nil)
            #expect(authController.currentUser == nil)
            expectation.fulfill()
        }

        await expectation.fulfillment()
        MockURLProtocol.reset()
    }

    // MARK: - Register Tests

    @Test func registerCreatesNewUser() async throws {
        // Given: Setup mock URL for register
        let registerURL = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/register")!
        MockURLProtocol.mockRegisterSuccess(url: registerURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController(urlSession: mockSession)
        let expectation = Expectation()

        // When: Register with valid details
        authController.register(name: "Mock User", email: "mock@example.com", password: "password123") { success, error in
            // Then: Registration should succeed and save user with ID
            #expect(success == true)
            #expect(error == nil)
            #expect(authController.currentUser != nil)
            #expect(authController.currentUser?.email == "mock@example.com")
            #expect(authController.currentUser?.name == "Mock User")
            #expect(authController.currentUser?.idToken == "mock-registered-user-id-456")
            expectation.fulfill()
        }

        await expectation.fulfillment()
        MockURLProtocol.reset()
    }

    @Test func registerPersistsUserIDToStorage() async throws {
        // Given: Setup mock URL for register
        let registerURL = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/register")!
        MockURLProtocol.mockRegisterSuccess(url: registerURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController(urlSession: mockSession)
        let expectation = Expectation()

        // When: Register with valid details
        authController.register(name: "Mock User", email: "mock@example.com", password: "password123") { success, error in
            // Then: User ID should be persisted to storage
            #expect(success == true)

            let storedData = UserDefaults.standard.data(forKey: "currentUser")
            #expect(storedData != nil)

            if let storedUser = try? JSONDecoder().decode(User.self, from: storedData!) {
                #expect(storedUser.idToken == "mock-registered-user-id-456")
                #expect(storedUser.email == "mock@example.com")
                #expect(storedUser.name == "Mock User")
            }

            expectation.fulfill()
        }

        await expectation.fulfillment()
        MockURLProtocol.reset()
    }

    @Test func registerWithExistingEmailFails() async throws {
        // Given: Setup mock URL with failure response
        let registerURL = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/register")!
        MockURLProtocol.mockRegisterFailure(url: registerURL)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)

        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController(urlSession: mockSession)
        let expectation = Expectation()

        // When: Register with existing email
        authController.register(name: "Test User", email: "existing@example.com", password: "password123") { success, error in
            // Then: Registration should fail
            #expect(success == false)
            #expect(error != nil)
            #expect(authController.currentUser == nil)
            expectation.fulfill()
        }

        await expectation.fulfillment()
        MockURLProtocol.reset()
    }

    // MARK: - Guest Login Tests

    @Test func guestLoginCreatesGuestUser() async throws {
        // Given: Clear any existing user
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController()

        // When: Login as guest
        authController.loginAsGuest()

        // Then: Guest user should be created
        #expect(authController.currentUser != nil)
        #expect(authController.currentUser?.email == "guest@smartfit.app")
        #expect(authController.currentUser?.name == "Guest")
        #expect(authController.isAuthenticated() == true)
    }

    @Test func guestLoginPersistsToStorage() async throws {
        // Given: Clear any existing user
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController()

        // When: Login as guest
        authController.loginAsGuest()

        // Then: User should be persisted
        let storedData = UserDefaults.standard.data(forKey: "currentUser")
        #expect(storedData != nil)

        let storedUser = try? JSONDecoder().decode(User.self, from: storedData!)
        #expect(storedUser?.email == "guest@smartfit.app")
    }

    // MARK: - Sign Out Tests

    @Test func signOutClearsCurrentUser() async throws {
        // Given: Login as guest
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController()
        authController.loginAsGuest()
        #expect(authController.isAuthenticated() == true)

        // When: Sign out
        authController.signOut()

        // Then: User should be cleared
        #expect(authController.currentUser == nil)
        #expect(authController.isAuthenticated() == false)
    }

    @Test func signOutClearsStorage() async throws {
        // Given: Login as guest
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController()
        authController.loginAsGuest()

        // When: Sign out
        authController.signOut()

        // Then: Storage should be cleared
        let storedData = UserDefaults.standard.data(forKey: "currentUser")
        #expect(storedData == nil)
    }

    // MARK: - Persistence Tests

    @Test func userPersistsAcrossControllerInstances() async throws {
        // Given: Clear and login as guest
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController1 = AuthenticationController()
        authController1.loginAsGuest()

        // When: Create new controller instance
        let authController2 = AuthenticationController()

        // Then: User should be loaded from storage
        #expect(authController2.currentUser != nil)
        #expect(authController2.currentUser?.email == "guest@smartfit.app")
        #expect(authController2.isAuthenticated() == true)
    }

    @Test func isAuthenticatedReturnsTrueWhenUserExists() async throws {
        // Given: Login as guest
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController()
        authController.loginAsGuest()

        // Then: Should be authenticated
        #expect(authController.isAuthenticated() == true)
    }

    @Test func isAuthenticatedReturnsFalseWhenNoUser() async throws {
        // Given: Clear any existing user
        UserDefaults.standard.removeObject(forKey: "currentUser")
        UserDefaults.standard.synchronize()

        let authController = AuthenticationController()

        // Then: Should not be authenticated
        #expect(authController.isAuthenticated() == false)
    }
}

// Helper for async expectations
class Expectation {
    private var isFulfilled = false

    func fulfill() {
        isFulfilled = true
    }

    func fulfillment() async {
        // Wait up to 10 seconds for fulfillment
        for _ in 0..<100 {
            if isFulfilled {
                return
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
}
