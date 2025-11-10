import Foundation
import PhotosUI
import SwiftUI

class WardrobeController: ObservableObject {
    @Published var model = WardrobeModel()
    @Published var selectedCategory = "all"
    @Published var selectedOutfit = 1 {
        didSet {
            saveOutfits()
        }
    }
    @Published var showAddSheet = false
    @Published var outfits: [Int: [String: String]] = [1: [:], 2: [:], 3: [:]]

    // Loading state for initial wardrobe fetch
    @Published var isLoading = false
    @Published var hasLoadedItems = false

    var currentEquippedOutfit: [String: String] {
        outfits[selectedOutfit] ?? [:]
    }

    // Add item form state
    @Published var formName = ""
    @Published var formCategory = "tops"
    @Published var formBrand = ""
    @Published var formSelectedImage: PhotosPickerItem?
    @Published var formImageData: Data?
    @Published var formIsLoading = false
    @Published var formErrorMessage: String?

    // NEW FIELDS
    @Published var formColor = ""
    @Published var formSize = "M"
    @Published var formPrice = ""
    @Published var formMaterial = ""
    @Published var formItemUrl = ""

    let categories = ["all", "tops", "bottoms", "shoes", "outerwear", "accessories"]
    let formCategories = ["tops", "bottoms", "shoes", "outerwear", "accessories"]
    let sizeOptions = ["XS", "S", "M", "L", "XL", "XXL", "Custom"]

    init(model: WardrobeModel = WardrobeModel()) {
        self.model = model
    }

    var filteredItems: [WardrobeItem] {
        if selectedCategory == "all" {
            return model.items
        }
        return model.items.filter { $0.category == selectedCategory }
    }

    func loadItems() {
        // Only load items once
        guard !hasLoadedItems else { return }

        Task {
            await MainActor.run {
                self.isLoading = true
            }

            do {
                try await model.fetchItems()
                if !loadOutfits() {
                    await MainActor.run {
                        self.outfits = [1: [:], 2: [:], 3: [:]]
                    }
                }
                await MainActor.run {
                    self.isLoading = false
                    self.hasLoadedItems = true
                }
            } catch {
                print("Error loading items: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.hasLoadedItems = true
                }
            }
        }
    }

    func saveOutfits() {
        do {
            let data = try JSONEncoder().encode(outfits)
            UserDefaults.standard.set(data, forKey: "savedOutfits")
        } catch {
            print("Error saving outfits: \(error)")
        }
    }

    func loadOutfits() -> Bool {
        if let data = UserDefaults.standard.data(forKey: "savedOutfits") {
            do {
                let decoded = try JSONDecoder().decode([Int: [String: String]].self, from: data)
                DispatchQueue.main.async {
                    self.outfits = decoded
                }
                return true
            } catch {
                print("Error loading outfits: \(error)")
                return false
            }
        }
        return false
    }

    func submitAddItem() {
        guard !formName.isEmpty else {
            formErrorMessage = "Name is required"
            return
        }

        guard !formColor.isEmpty else {
            formErrorMessage = "Color is required"
            return
        }

        formIsLoading = true
        Task {
            do {
                try await model.addItem(
                    name: formName,
                    category: formCategory,
                    brand: formBrand,
                    color: formColor,
                    size: formSize,
                    price: formPrice,
                    material: formMaterial,
                    itemUrl: formItemUrl,
                    imageData: formImageData
                )
                await MainActor.run {
                    self.resetForm()
                    self.showAddSheet = false
                }
            } catch {
                await MainActor.run {
                    self.formErrorMessage = "Failed to add item: \(error.localizedDescription)"
                    self.formIsLoading = false
                }
                print("Error adding item: \(error)")
            }
        }
    }

    func resetForm() {
        formName = ""
        formCategory = "tops"
        formBrand = ""
        formColor = ""
        formSize = "M"
        formPrice = ""
        formMaterial = ""
        formItemUrl = ""
        formSelectedImage = nil
        formImageData = nil
        formIsLoading = false
        formErrorMessage = nil
    }

    func equipItem(itemId: String, category: String) {
        print("Equipping item \(itemId) in category \(category) to outfit \(selectedOutfit)")
        var updatedOutfits = outfits
        updatedOutfits[selectedOutfit]?[category] = itemId
        outfits = updatedOutfits
        print("Updated outfit \(selectedOutfit): \(currentEquippedOutfit)")
        saveOutfits()
    }
}
