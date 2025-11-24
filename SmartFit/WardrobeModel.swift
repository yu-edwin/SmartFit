import Foundation
import UIKit

struct WardrobeItem: Identifiable, Codable {
    let id: String
    let userId: String
    let category: String
    let name: String
    let brand: String?
    // swiftlint:disable:next identifier_name
    let image_data: String?
    let price: Double?
    let color: String?
    let size: String?
    let material: String?
    // swiftlint:disable:next identifier_name
    let item_url: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        // swiftlint:disable:next identifier_name
        case userId, category, name, brand, image_data, price
        // swiftlint:disable:next identifier_name
        case color, size, material, item_url
    }
}

struct UpdateWardrobeResponse: Codable {
    let message: String
    let data: WardrobeItem
}

class WardrobeModel: ObservableObject {
    @Published var items: [WardrobeItem] = []

    private let baseURL = "https://smartfit-d9yj.onrender.com/api/wardrobe"
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    private func getCurrentUserId() -> String? {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user.idToken
    }

    func fetchItems() async throws {
        guard let userId = getCurrentUserId() else {
            throw NSError(domain: "User not logged in", code: -1)
        }

        guard let url = URL(string: "\(baseURL)?userId=\(userId)") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }

        let (data, _) = try await urlSession.data(from: url)

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let dataArray = json["data"] as? [[String: Any]] {
            let itemsData = try JSONSerialization.data(withJSONObject: dataArray)
            let decoder = JSONDecoder()
            let decodedItems = try decoder.decode([WardrobeItem].self, from: itemsData)

            await MainActor.run {
                self.items = decodedItems
            }
        }
    }

    // swiftlint:disable:next function_parameter_count
    func addItem(
        name: String,
        category: String,
        brand: String,
        color: String,
        size: String,
        price: String,
        material: String,
        itemUrl: String?,
        imageData: Data?
    ) async throws {
        guard let userId = getCurrentUserId() else {
            throw NSError(domain: "User not logged in", code: -1)
        }

        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "userId": userId,
            "name": name,
            "category": category,
            "brand": brand,
            "color": color,
            "size": size.uppercased()
        ]

        if !price.isEmpty, let priceValue = Double(price), priceValue > 0 {
            body["price"] = priceValue
        }

        if !material.isEmpty {
            body["material"] = material
        }

        if let itemUrl = itemUrl {
            body["item_url"] = itemUrl
        }

        if let imageData = imageData {
            let base64 = "data:image/jpeg;base64," + imageData.base64EncodedString()
            body["image_data"] = base64
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await urlSession.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
                throw NSError(
                    domain: "Server Error",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to add item"]
                )
            }
        }

        try await fetchItems()
    }

    // Main call for PUT request wardrobeItem (clothingItem)
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func updateItem(
        itemId: String,
        name: String? = nil,
        category: String? = nil,
        brand: String? = nil,
        color: String? = nil,
        size: String? = nil,
        price: Double? = nil,
        material: String? = nil,
        itemUrl: String? = nil,
        imageData: Data? = nil
    ) async throws {
        // 1. Build URL: /api/wardrobe/:id
        guard let url = URL(string: "\(baseURL)/\(itemId)") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 2. Build body with only non-nil values (partial update)
        var body: [String: Any] = [:]

        if let name = name {
            body["name"] = name
        }
        if let category = category {
            body["category"] = category
        }
        if let brand = brand {
            body["brand"] = brand
        }
        if let color = color {
            body["color"] = color
        }
        if let size = size {
            body["size"] = size.uppercased()
        }
        if let price = price {
            body["price"] = price
        }
        if let material = material {
            body["material"] = material
        }
        if let itemUrl = itemUrl {
            body["item_url"] = itemUrl
        }
        if let imageData = imageData {
            let base64 = "data:image/jpeg;base64," + imageData.base64EncodedString()
            body["image_data"] = base64
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // 3. Send request
        let (data, response) = try await urlSession.data(for: request)

        // 4. Check status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: -1)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(
                domain: "Server Error",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to update item"]
            )
        }

        // 5. Decode response: { message, data: { ...updated WardrobeItem... } }
        let decoder = JSONDecoder()
        let updatedResponse = try decoder.decode(UpdateWardrobeResponse.self, from: data)
        let updatedItem = updatedResponse.data

        // 6. Update local items array so UI refreshes
        await MainActor.run {
            if let index = self.items.firstIndex(where: { $0.id == updatedItem.id }) {
                self.items[index] = updatedItem
            }
        }
    }

    func updateOutfit(outfitNumber: Int, category: String, itemId: String) async throws {
        print("=== WardrobeModel.updateOutfit called ===")
        print("Outfit: \(outfitNumber), Category: \(category), ItemId: \(itemId)")

        guard let userId = getCurrentUserId() else {
            print("ERROR: User not logged in")
            throw NSError(domain: "User not logged in", code: -1)
        }
        print("User ID: \(userId)")

        let userBaseURL = "https://smartfit-d9yj.onrender.com/api/user"
        let urlString = "\(userBaseURL)/\(userId)/\(outfitNumber)/\(category)/\(itemId)"
        print("URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("ERROR: Invalid URL")
            throw NSError(domain: "Invalid URL", code: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("Sending PATCH request to backend...")

        let (data, response) = try await urlSession.data(for: request)
        print("=== Received response from backend ===")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("ERROR: Invalid response type")
            throw NSError(domain: "Invalid response", code: -1)
        }

        print("HTTP Status Code: \(httpResponse.statusCode)")

        guard (200..<300).contains(httpResponse.statusCode) else {
            print("ERROR: Server returned error status code")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            throw NSError(
                domain: "Server Error",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to update outfit"]
            )
        }

        print("Successfully updated outfit on backend")
    }

    func generateOutfit(outfitNumber: Int, picture: UIImage) async throws -> String {
        print("=== WardrobeModel.generateOutfit called ===")
        print("Outfit number: \(outfitNumber)")

        guard let userId = getCurrentUserId() else {
            print("ERROR: User not logged in")
            throw NSError(domain: "User not logged in", code: -1)
        }
        print("User ID: \(userId)")

        let userBaseURL = "https://smartfit-d9yj.onrender.com/api/user"
        let urlString = "\(userBaseURL)/\(userId)/generate-outfit/\(outfitNumber)"
        print("URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("ERROR: Invalid URL")
            throw NSError(domain: "Invalid URL", code: -1)
        }

        // Convert UIImage to base64 data URL
        print("Converting image to base64...")
        guard let imageData = picture.jpegData(compressionQuality: 0.8) else {
            print("ERROR: Failed to convert image to JPEG data")
            throw NSError(domain: "Failed to convert image", code: -1)
        }
        print("Image data size: \(imageData.count) bytes")
        let base64Picture = "data:image/jpeg;base64," + imageData.base64EncodedString()
        print("Base64 string length: \(base64Picture.count)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
                  "picture": base64Picture
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        print("Request body size: \(request.httpBody?.count ?? 0) bytes")
        print("Sending POST request to backend...")

        let (data, response) = try await urlSession.data(for: request)
        print("=== Received response from backend ===")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("ERROR: Invalid response type")
            throw NSError(domain: "Invalid response", code: -1)
        }

        print("HTTP Status Code: \(httpResponse.statusCode)")

        guard (200..<300).contains(httpResponse.statusCode) else {
            print("ERROR: Server returned error status code")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
            throw NSError(
                domain: "Server Error",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to generate outfit"]
            )
        }

        // Parse response to get generated image
        print("Parsing response JSON...")
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("JSON keys: \(json.keys)")
            if let generatedImage = json["generatedImage"] as? String {
                print("Successfully extracted generatedImage from response")
                print("Generated image length: \(generatedImage.count)")
                return generatedImage
            } else {
                print("ERROR: generatedImage key not found in response")
                print("Full response: \(json)")
            }
        } else {
            print("ERROR: Response is not a valid JSON dictionary")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response body: \(responseString)")
            }
        }
        throw NSError(domain: "Invalid response format", code: -1)
      
      
     
    func importFromUrl(productUrl: String, size: String) async throws {
        guard let userId = getCurrentUserId() else {
            throw NSError(domain: "User not logged in", code: -1)
        }

        guard let url = URL(string: "\(baseURL)/import-url") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userId,
            "productUrl": productUrl,
            "size": size.uppercased()
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await urlSession.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Import response: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 201 && httpResponse.statusCode != 200 {
                throw NSError(domain: "Import failed", code: httpResponse.statusCode)
            }
        }

        try await fetchItems()
    }
}
