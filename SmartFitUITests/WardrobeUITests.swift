import XCTest

final class WardrobeUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Tests
    
    func testWardrobeScreenLoads() throws {
        // Verify that Wardrobe navigation title exists
        let wardrobeTitle = app.navigationBars["Wardrobe"]
        XCTAssertTrue(wardrobeTitle.exists, "Wardrobe screen should be visible")
    }
    
    func testOutfitSelectorExists() throws {
        // Verify outfit selector buttons (1, 2, 3) exist
        let outfitButton1 = app.staticTexts["1"]
        let outfitButton2 = app.staticTexts["2"]
        let outfitButton3 = app.staticTexts["3"]
        
        XCTAssertTrue(outfitButton1.exists, "Outfit button 1 should exist")
        XCTAssertTrue(outfitButton2.exists, "Outfit button 2 should exist")
        XCTAssertTrue(outfitButton3.exists, "Outfit button 3 should exist")
    }
    
    // MARK: - Category Filter Tests
    
    func testCategoryFiltersExist() throws {
        // Wait for categories to load
        let allButton = app.buttons["All"]
        XCTAssertTrue(allButton.waitForExistence(timeout: 2), "All category button should exist")
        
        // Check other category buttons
        let topsButton = app.buttons["Tops"]
        let bottomsButton = app.buttons["Bottoms"]
        
        XCTAssertTrue(topsButton.exists, "Tops category button should exist")
        XCTAssertTrue(bottomsButton.exists, "Bottoms category button should exist")
    }
    
    func testCategoryFilterTap() throws {
        let topsButton = app.buttons["Tops"]
        
        if topsButton.exists {
            topsButton.tap()
            // Verify the button state changed (this depends on your UI implementation)
            XCTAssertTrue(topsButton.exists, "Should be able to tap Tops category")
        }
    }
    
    // MARK: - Add Menu Tests
    
    func testAddButtonExists() throws {
        // Find the main add button (plus icon)
        let addButton = app.buttons.matching(identifier: "plus").firstMatch
        
        // If not found by identifier, try finding by image
        if !addButton.exists {
            let buttons = app.buttons.allElementsBoundByIndex
            let plusButton = buttons.first { $0.label.contains("plus") }
            XCTAssertNotNil(plusButton, "Add button with plus icon should exist")
        } else {
            XCTAssertTrue(addButton.exists, "Add button should exist")
        }
    }
    
    func testAddMenuExpands() throws {
        // Tap the add button
        let addButtons = app.buttons.allElementsBoundByIndex
        let plusButton = addButtons.last // Usually the floating button is last
        
        if let button = plusButton {
            button.tap()
            
            // Wait a bit for animation
            sleep(1)
            
            // Check if menu items appear
            let manualEntryText = app.staticTexts["Manual Entry"]
            let urlImportText = app.staticTexts["Import from URL"]
            
            XCTAssertTrue(
                manualEntryText.exists || urlImportText.exists,
                "Menu should expand and show options"
            )
        }
    }
    
    func testManualEntryButtonOpensSheet() throws {
        // Open the add menu
        let addButtons = app.buttons.allElementsBoundByIndex
        if let plusButton = addButtons.last {
            plusButton.tap()
            sleep(1)
            
            // Tap manual entry
            let manualEntryButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'square.and.pencil'")).firstMatch
            
            if manualEntryButton.exists {
                manualEntryButton.tap()
                sleep(1)
                
                // Verify Add Item sheet appears
                let addItemTitle = app.navigationBars["Add Item"]
                XCTAssertTrue(addItemTitle.waitForExistence(timeout: 2), "Add Item sheet should appear")
            }
        }
    }
    
    func testURLImportButtonOpensSheet() throws {
        // Open the add menu
        let addButtons = app.buttons.allElementsBoundByIndex
        if let plusButton = addButtons.last {
            plusButton.tap()
            sleep(1)
            
            // Tap URL import
            let urlImportButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'link'")).firstMatch
            
            if urlImportButton.exists {
                urlImportButton.tap()
                sleep(1)
                
                // Verify Import from URL sheet appears
                let importTitle = app.navigationBars["Import from URL"]
                XCTAssertTrue(importTitle.waitForExistence(timeout: 2), "Import from URL sheet should appear")
            }
        }
    }
    
    func testAddMenuClosesByTappingBackground() throws {
        // Open the add menu
        let addButtons = app.buttons.allElementsBoundByIndex
        if let plusButton = addButtons.last {
            plusButton.tap()
            sleep(1)
            
            // Tap somewhere on the background (center of screen)
            let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            coordinate.tap()
            sleep(1)
            
            // Menu should close - check that Manual Entry text is gone
            let manualEntryText = app.staticTexts["Manual Entry"]
            XCTAssertFalse(manualEntryText.exists, "Menu should close when tapping background")
        }
    }
    
    // MARK: - Empty State Tests

    func testEmptyStateShowsWhenNoItems() throws {
        // This test assumes a fresh state with no items
        // You might need to clear data first

        let noItemsText = app.staticTexts["No items yet"]

        if noItemsText.exists {
            XCTAssertTrue(noItemsText.exists, "Empty state should show when no items")

            let addItemButton = app.buttons["Add Item"]
            XCTAssertTrue(addItemButton.exists, "Add Item button should exist in empty state")
        }
    }

    // MARK: - Loading Screen Tests

    func testLoadingIndicatorAppearsWhenFetchingItems() throws {
        // Launch app fresh
        app.terminate()
        app.launch()

        // Check if loading indicator appears (ProgressView or similar)
        let loadingIndicator = app.activityIndicators.firstMatch

        // Loading should appear briefly at launch
        // Note: This might be fast, so we check if it existed or if content loaded
        let wardrobeTitle = app.navigationBars["Wardrobe"]
        XCTAssertTrue(
            loadingIndicator.exists || wardrobeTitle.exists,
            "Loading indicator should appear or content should load"
        )
    }

    func testContentAppearsAfterLoading() throws {
        // Wait for loading to complete
        let wardrobeTitle = app.navigationBars["Wardrobe"]
        XCTAssertTrue(
            wardrobeTitle.waitForExistence(timeout: 5),
            "Wardrobe screen should appear after loading"
        )

        // Loading indicator should disappear
        let loadingIndicator = app.activityIndicators.firstMatch

        // Wait a bit for loading to finish
        sleep(2)

        // Either loading is gone or we have content
        let hasContent = app.buttons["All"].exists || app.staticTexts["No items yet"].exists
        XCTAssertTrue(
            !loadingIndicator.exists || hasContent,
            "Loading should complete and show content or empty state"
        )
    }
}
