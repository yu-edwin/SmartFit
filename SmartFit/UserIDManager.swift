//
//  UserIDManager.swift
//  SmartFit
//
//  Created by Edwin Yu
//

import Foundation

class UserIDManager {
    static let shared = UserIDManager()

    var userID: String {
        if let id = UserDefaults.standard.string(forKey: "userID") {
            return id
        }

        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: "userID")
        return id
    }
}
