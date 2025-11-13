//
//  Environment.swift
//  SmartFit
//
//  Created by Claude Code
//

import Foundation

enum Environment {
    case production
    case development
    case local

    // Automatically detects environment based on launch arguments
    // To use localhost: Edit Scheme → Arguments → add "-LOCAL"
    // To test production in debug: Edit Scheme → Arguments → add "-PRODUCTION"
    static var current: Environment {
        #if DEBUG
        // Check for launch arguments to override environment
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-LOCAL") {
            return .local
        } else if arguments.contains("-PRODUCTION") {
            return .production
        }
        return .development  // Default for debug builds
        #else
        return .production   // Release builds always use production
        #endif
    }

    var baseURL: String {
        switch self {
        case .production:
            return "https://smartfit-backend-lhz4.onrender.com"
        case .development:
            return "https://smartfit-development.onrender.com"
        case .local:
            return "http://localhost:3000"
        }
    }
}
