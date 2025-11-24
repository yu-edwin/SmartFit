import XCTest
@testable import SmartFit

final class WardrobeViewTests: XCTestCase {
    var controller: WardrobeController!
    
    override func setUpWithError() throws {
        controller = WardrobeController()
    }
    
    override func tearDownWithError() throws {
        controller = nil
    }
    
    // MARK: - Initialization Tests
    
    func testControllerInitialization() throws {
        XCTAssertNotNil(controller, "Controller should initialize")
        XCTAssertEqual(controller.selectedCategory, "all", "Default category should be 'all'")
        XCTAssertEqual(controller.selectedOutfit, 1, "Default outfit should be 1")
        XCTAssertFalse(controller.showAddSheet, "Add sheet should be hidden initially")
        XCTAssertFalse(controller.showUrlImportSheet, "URL import sheet should be hidden initially")
    }
    
    func testCategoriesListExists() throws {
        XCTAssertFalse(controller.categories.isEmpty, "Categories list should not be empty")
        XCTAssertTrue(controller.categories.contains("all"), "Categories should contain 'all'")
        XCTAssertTrue(controller.categories.contains("tops"), "Categories should contain 'tops'")
        XCTAssertTrue(controller.categories.contains("bottoms"), "Categories should contain 'bottoms'")
    }
    
    // MARK: - Category Filter Tests
    
    func testCategorySelection() throws {
        controller.selectedCategory = "tops"
        XCTAssertEqual(controller.selectedCategory, "tops", "Selected category should update to tops")
        
        controller.selectedCategory = "bottoms"
        XCTAssertEqual(controller.selectedCategory, "bottoms", "Selected category should update to bottoms")
        
        controller.selectedCategory = "all"
        XCTAssertEqual(controller.selectedCategory, "all", "Selected category should update to all")
    }
    
    func testFilteredItemsForAllCategory() throws {
        // Create mock items
        let mockItem1 = WardrobeItem(
            id: "1",
            userId: "testUser123",
            category: "tops",
            name: "T-Shirt",
            brand: "TestBrand",
            image_data: nil,
            price: 20.0,
            color: "Blue",
            size: "M",
            material: "Cotton",
            item_url: nil
        )
        
        let mockItem2 = WardrobeItem(
            id: "2",
            userId: "testUser123",
            category: "bottoms",
            name: "Jeans",
            brand: "TestBrand",
            image_data: nil,
            price: 50.0,
            color: "Blue",
            size: "M",
            material: "Denim",
            item_url: nil
        )
        
        controller.model.items = [mockItem1, mockItem2]
        controller.selectedCategory = "all"
        
        XCTAssertEqual(controller.filteredItems.count, 2, "All category should show all items")
    }
    
    func testFilteredItemsForSpecificCategory() throws {
        let mockItem1 = WardrobeItem(
            id: "1",
            userId: "testUser123",
            category: "tops",
            name: "T-Shirt",
            brand: nil,
            image_data: nil,
            price: nil,
            color: nil,
            size: nil,
            material: nil,
            item_url: nil
        )
        
        let mockItem2 = WardrobeItem(
            id: "2",
            userId: "testUser123",
            category: "bottoms",
            name: "Jeans",
            brand: nil,
            image_data: nil,
            price: nil,
            color: nil,
            size: nil,
            material: nil,
            item_url: nil
        )
        
        controller.model.items = [mockItem1, mockItem2]
        controller.selectedCategory = "tops"
        
        XCTAssertEqual(controller.filteredItems.count, 1, "Tops category should show only tops")
        XCTAssertEqual(controller.filteredItems.first?.category, "tops", "Filtered item should be tops")
    }
    
    // MARK: - Outfit Selection Tests
    
    func testOutfitSelection() throws {
        controller.selectedOutfit = 1
        XCTAssertEqual(controller.selectedOutfit, 1, "Should select outfit 1")
        
        controller.selectedOutfit = 2
        XCTAssertEqual(controller.selectedOutfit, 2, "Should select outfit 2")
        
        controller.selectedOutfit = 3
        XCTAssertEqual(controller.selectedOutfit, 3, "Should select outfit 3")
    }
    
    func testEquipItem() throws {
        let testItemId = "testItem123"
        let testCategory = "tops"
        
        controller.equipItem(itemId: testItemId, category: testCategory)
        
        let equippedItem = controller.currentEquippedOutfit[testCategory]
        XCTAssertEqual(equippedItem, testItemId, "Item should be equipped in current outfit")
    }
    
    // MARK: - Form State Tests
    
    func testFormInitialState() throws {
        XCTAssertTrue(controller.formName.isEmpty, "Form name should be empty initially")
        XCTAssertEqual(controller.formCategory, "tops", "Form category should default to tops")
        XCTAssertTrue(controller.formBrand.isEmpty, "Form brand should be empty initially")
        XCTAssertTrue(controller.formColor.isEmpty, "Form color should be empty initially")
        XCTAssertEqual(controller.formSize, "M", "Form size should default to M")
        XCTAssertNil(controller.formImageData, "Form image data should be nil initially")
    }
    
    func testResetForm() throws {
        // Set some form values
        controller.formName = "Test Item"
        controller.formBrand = "Test Brand"
        controller.formColor = "Blue"
        controller.formPrice = "29.99"
        controller.formMaterial = "Cotton"
        
        // Reset form
        controller.resetForm()
        
        // Verify all fields are reset
        XCTAssertTrue(controller.formName.isEmpty, "Form name should be empty after reset")
        XCTAssertTrue(controller.formBrand.isEmpty, "Form brand should be empty after reset")
        XCTAssertTrue(controller.formColor.isEmpty, "Form color should be empty after reset")
        XCTAssertTrue(controller.formPrice.isEmpty, "Form price should be empty after reset")
        XCTAssertTrue(controller.formMaterial.isEmpty, "Form material should be empty after reset")
        XCTAssertEqual(controller.formCategory, "tops", "Form category should reset to tops")
        XCTAssertEqual(controller.formSize, "M", "Form size should reset to M")
    }
    
    // MARK: - URL Import Tests
    
    func testUrlImportInitialState() throws {
        XCTAssertTrue(controller.urlToImport.isEmpty, "URL to import should be empty initially")
        XCTAssertEqual(controller.urlImportSize, "M", "URL import size should default to M")
        XCTAssertFalse(controller.isImportingUrl, "Should not be importing initially")
        XCTAssertNil(controller.urlImportError, "URL import error should be nil initially")
    }
    
    // MARK: - Size Options Tests
    
    func testSizeOptionsExist() throws {
        XCTAssertFalse(controller.sizeOptions.isEmpty, "Size options should not be empty")
        XCTAssertTrue(controller.sizeOptions.contains("XS"), "Size options should contain XS")
        XCTAssertTrue(controller.sizeOptions.contains("S"), "Size options should contain S")
        XCTAssertTrue(controller.sizeOptions.contains("M"), "Size options should contain M")
        XCTAssertTrue(controller.sizeOptions.contains("L"), "Size options should contain L")
        XCTAssertTrue(controller.sizeOptions.contains("XL"), "Size options should contain XL")
    }
    
    // MARK: - Edit Form Tests
    
    func testStartEditing() throws {
        let mockItem = WardrobeItem(
            id: "test123",
            userId: "user123",
            category: "tops",
            name: "Test Shirt",
            brand: "TestBrand",
            image_data: nil,
            price: 29.99,
            color: "Blue",
            size: "L",
            material: "Cotton",
            item_url: "https://example.com"
        )
        
        controller.startEditing(mockItem)
        
        XCTAssertTrue(controller.showEditSheet, "Edit sheet should be shown")
        XCTAssertEqual(controller.editName, "Test Shirt", "Edit name should match item")
        XCTAssertEqual(controller.editCategory, "tops", "Edit category should match item")
        XCTAssertEqual(controller.editBrand, "TestBrand", "Edit brand should match item")
        XCTAssertEqual(controller.editColor, "Blue", "Edit color should match item")
        XCTAssertEqual(controller.editSize, "L", "Edit size should match item")
        XCTAssertEqual(controller.editMaterial, "Cotton", "Edit material should match item")
    }
    
    // MARK: - Info Display Tests
    
    func testShowInfo() throws {
        let mockItem = WardrobeItem(
            id: "test123",
            userId: "user123",
            category: "tops",
            name: "Test Shirt",
            brand: "TestBrand",
            image_data: nil,
            price: 29.99,
            color: "Blue",
            size: "M",
            material: "Cotton",
            item_url: nil
        )
        
        controller.showInfo(for: mockItem)
        
        XCTAssertTrue(controller.showInfoSheet, "Info sheet should be shown")
        XCTAssertNotNil(controller.infoItem, "Info item should be set")
        XCTAssertEqual(controller.infoItem?.id, "test123", "Info item should match")
    }
    
    // MARK: - Performance Tests
    
    func testFilterPerformance() throws {
        // Create 100 mock items
        var mockItems: [WardrobeItem] = []
        for i in 0..<100 {
            let category = i % 2 == 0 ? "tops" : "bottoms"
            let item = WardrobeItem(
                id: "\(i)",
                userId: "testUser",
                category: category,
                name: "Item \(i)",
                brand: nil,
                image_data: nil,
                price: nil,
                color: nil,
                size: nil,
                material: nil,
                item_url: nil
            )
            mockItems.append(item)
        }
        
        controller.model.items = mockItems
        
        measure {
            controller.selectedCategory = "tops"
            _ = controller.filteredItems
        }
    }
}
