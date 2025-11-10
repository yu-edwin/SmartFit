//
//  AuthenticationController.swift
//  SmartFit
//
//  Created by Edwin Yu
//

import Foundation
import UIKit

protocol AuthenticationDelegate: AnyObject {
    func didSignIn(user: User)
    func didSignOut()
    func didFailWithError(_ error: Error)
}

class AuthenticationController: ObservableObject {

    weak var delegate: AuthenticationDelegate?

    private let userDefaultsKey = "currentUser"
    @Published var currentUser: User?
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        loadUserFromStorage()
    }

    // MARK: - Authentication Methods

    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/login") else {
            completion(false, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }

                guard let data = data else {
                    completion(false, "No data received")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    if let json = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        let user = User(email: json.user.email, name: json.user.name, idToken: json.user.id)
                        self.currentUser = user
                        self.saveUserToStorage(user)
                        self.delegate?.didSignIn(user: user)
                        completion(true, nil)
                    } else {
                        completion(false, "Failed to parse response")
                    }
                } else {
                    if let json = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        completion(false, json.message)
                    } else {
                        completion(false, "Login failed")
                    }
                }
            }
        }.resume()
    }

    func register(name: String, email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "https://smartfit-backend-lhz4.onrender.com/api/user/register") else {
            completion(false, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["name": name, "email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }

                guard let data = data else {
                    completion(false, "No data received")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 201 {
                    // Parse the registration response which now includes user data
                    if let json = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        let user = User(email: json.user.email, name: json.user.name, idToken: json.user.id)
                        self.currentUser = user
                        self.saveUserToStorage(user)
                        self.delegate?.didSignIn(user: user)
                        completion(true, nil)
                    } else {
                        completion(false, "Failed to parse registration response")
                    }
                } else {
                    if let json = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        completion(false, json.message)
                    } else {
                        completion(false, "Registration failed")
                    }
                }
            }
        }.resume()
    }

    func loginAsGuest() {
        let guestEmail = "guest@smartfit.app"
        let user = User(email: guestEmail, name: "Guest", idToken: UserIDManager.shared.userID)
        self.currentUser = user
        saveUserToStorage(user)
        delegate?.didSignIn(user: user)
    }

    func signOut() {
        currentUser = nil
        clearUserFromStorage()
        delegate?.didSignOut()
    }

    func isAuthenticated() -> Bool {
        return currentUser != nil
    }

    // MARK: - Persistence

    private func saveUserToStorage(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadUserFromStorage() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
        }
    }

    private func clearUserFromStorage() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

// MARK: - Response Models
struct LoginResponse: Codable {
    let message: String
    let user: UserResponse
}

struct UserResponse: Codable {
    let id: String
    let name: String
    let email: String
}

struct ErrorResponse: Codable {
    let message: String
}
