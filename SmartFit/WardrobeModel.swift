import Foundation

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

class WardrobeModel: ObservableObject {
    @Published var items: [WardrobeItem] = []


    private let baseURL = "https://smartfit-backend-lhz4.onrender.com/api/wardrobe"
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
        itemUrl: String,
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

        if !itemUrl.isEmpty {
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
                    domain: "Server Error", code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to add item"]
                )
            }
        }

        try await fetchItems()
    }
}
