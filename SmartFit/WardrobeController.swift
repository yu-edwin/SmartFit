import Foundation
import PhotosUI
import SwiftUI
import Combine

class WardrobeController: ObservableObject { // swiftlint:disable:this type_body_length
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

    // Edit form states for PUT Request Update clothing item
    @Published var editingItem: WardrobeItem?
    @Published var showEditSheet = false
    @Published var editName = ""
    @Published var editCategory = "tops"
    @Published var editBrand = ""
    @Published var editColor = ""
    @Published var editSize = "M"
    @Published var editPrice = ""
    @Published var editMaterial = ""
    @Published var editItemUrl = ""
    @Published var editSelectedImage: PhotosPickerItem?
    @Published var editImageData: Data?

    // Variables for info displayed for each wardrobeItem
    @Published var showInfoSheet = false
    @Published var infoItem: WardrobeItem?

    let categories = ["all", "tops", "bottoms", "shoes", "outerwear", "accessories"]
    let formCategories = ["tops", "bottoms", "shoes", "outerwear", "accessories"]
    let sizeOptions = ["XS", "S", "M", "L", "XL", "XXL", "Custom"]

    private var cancellables = Set<AnyCancellable>()

    init(model: WardrobeModel = WardrobeModel()) {
        self.model = model
        model.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var filteredItems: [WardrobeItem] {
        if selectedCategory == "all" {
            return model.items
        }
        return model.items.filter { $0.category == selectedCategory }
    }

    func loadItems() {
        // // Only load items once
        // guard !hasLoadedItems else { return }

        Task {
            await MainActor.run {
                self.isLoading = true
            }

            do {
                try await model.fetchItems()
                if model.items.isEmpty {
                    await seedStarterWardrobeIfNeeded()
                }
                if !loadOutfits() {
                    await MainActor.run {
                        self.outfits = [1: [:], 2: [:], 3: [:]]
                    }
                }

            } catch {
                print("Error loading items: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.hasLoadedItems = true
                }
            }
            await MainActor.run {
                self.isLoading = false
                self.hasLoadedItems = true
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

    // Function for PUT clothingItem request
    func startEditing(_ item: WardrobeItem) {
        editingItem = item
        editName = item.name
        editCategory = item.category
        editBrand = item.brand ?? ""
        editColor = item.color ?? ""
        editSize = item.size ?? "M"
        editPrice = item.price != nil ? String(item.price!) : ""
        editMaterial = item.material ?? ""
        editItemUrl = item.item_url ?? ""
        editSelectedImage = nil
        editImageData = nil
        showEditSheet = true
    }

    // PUT clothingItem request. Ensures quality in updated info and calls request
    // swiftlint:disable:next function_body_length
    func submitEdit() {
        guard let item = editingItem else { return }

        Task {
            do {
                var newPrice: Double?
                if !editPrice.isEmpty, let val = Double(editPrice) {
                    newPrice = val
                }
                let nameToSend: String? =
                    (editName == item.name) ? nil : editName

                let categoryToSend: String? =
                    (editCategory == item.category) ? nil : editCategory
                let originalBrand = item.brand ?? ""
                let brandToSend: String? =
                    (editBrand == originalBrand) ? nil : editBrand
                let originalColor = item.color ?? ""
                let colorToSend: String? =
                    (editColor == originalColor) ? nil : editColor
                let originalSize = item.size ?? ""
                let sizeToSend: String? =
                    (editSize == originalSize) ? nil : editSize
                let originalMaterial = item.material ?? ""
                let materialToSend: String? =
                    (editMaterial == originalMaterial) ? nil : editMaterial
                let originalItemUrl = item.item_url ?? ""
                let itemUrlToSend: String? =
                    (editItemUrl == originalItemUrl) ? nil : editItemUrl
                let originalPrice = item.price
                let priceToSend: Double? =
                    (originalPrice == newPrice) ? nil : newPrice
                let nothingChanged =
                    nameToSend == nil &&
                    categoryToSend == nil &&
                    brandToSend == nil &&
                    colorToSend == nil &&
                    sizeToSend == nil &&
                    priceToSend == nil &&
                    materialToSend == nil &&
                    itemUrlToSend == nil &&
                    editImageData == nil
                if nothingChanged {
                    await MainActor.run {
                        self.showEditSheet = false
                    }
                    return
                }
                try await model.updateItem(
                    itemId: item.id,
                    name: nameToSend,
                    category: categoryToSend,
                    brand: brandToSend,
                    color: colorToSend,
                    size: sizeToSend,
                    price: priceToSend,
                    material: materialToSend,
                    itemUrl: itemUrlToSend,
                    imageData: editImageData
                )
                try await model.fetchItems()
                await MainActor.run {
                    self.objectWillChange.send()
                    self.showEditSheet = false
                }
                print("PUT succeeded for item \(item.id)")
            } catch {
                print("PUT failed for item \(item.id): \(error)")
            }
        }
    }

    // Helper method for displaying info sheet for each clothing item
    func showInfo(for item: WardrobeItem) {
        infoItem = item
        showInfoSheet = true
    }
    // Helper to turn a data URL like "data:image/jpeg;base64,..." into Data
    private func imageData(fromDataURL dataURL: String) -> Data? {
        // Split at the first comma: "data:image/jpeg;base64," | "<base64...>"
        guard let commaIndex = dataURL.firstIndex(of: ",") else { return nil }
        let base64String = String(dataURL[dataURL.index(after: commaIndex)...])
        return Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
    }

    // Seeds data into newly registered account
    // swiftlint:disable:next function_body_length
    private func seedStarterWardrobeIfNeeded() async {
        do {
            if !model.items.isEmpty {
                return
            }
            let scarfUrl = SeedImages.scarfUrl
            let sunglassesUrl = SeedImages.sunglassesUrl
            let jeansUrl = SeedImages.jeansUrl
            let tShirtUrl = SeedImages.tShirtUrl
            let hoodieUrl = SeedImages.hoodieUrl
            let scarfImageData = imageData(fromDataURL: scarfUrl)
            let sunglassesImageData = imageData(fromDataURL: sunglassesUrl)
            let jeansImageData = imageData(fromDataURL: jeansUrl)
            let tShirtImageData = imageData(fromDataURL: tShirtUrl)
            let hoodieImageData = imageData(fromDataURL: hoodieUrl)

            try await model.addItem(
                name: "Black Sunglasses",
                category: "accessories",
                brand: "Prada",
                color: "Black",
                size: "--",
                price: "39.99",
                material: "Titanium",
                itemUrl: "",
                imageData: sunglassesImageData
            )
            try await model.addItem(
                name: "Beige Check Scarf",
                category: "accessories",
                brand: "Uniqlo",
                color: "Beige",
                size: "M",
                price: "59.99",
                material: "Cotton",
                itemUrl: "",
                imageData: scarfImageData
            )
            try await model.addItem(
                name: "Demin Jeans",
                category: "bottoms",
                brand: "Hollister",
                color: "Blue",
                size: "M",
                price: "29.99",
                material: "Cotton",
                itemUrl: "",
                imageData: jeansImageData
            )
            try await model.addItem(
                name: "Navy T-Shirt",
                category: "tops",
                brand: "American Eagle",
                color: "Navy",
                size: "M",
                price: "20.99",
                material: "Cotton",
                itemUrl: "",
                imageData: tShirtImageData
            )
            try await model.addItem(
                name: "Hoodie",
                category: "outerwear",
                brand: "Nike",
                color: "Biege",
                size: "L",
                price: "40.99",
                material: "Cotton",
                itemUrl: "",
                imageData: hoodieImageData
            )
            print("Seeded starter wardrobe for this user")
        } catch {
            print("Failed to seed starter wardrobe: \(error)")
        }
    }
}
