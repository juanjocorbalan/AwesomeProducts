import XCTest

@MainActor
class AwesomeProductsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() async throws {
        app = XCUIApplication()
        continueAfterFailure = false
        app.launchArguments = ["-UITests"]
        app.launch()
    }
    
    func test_ProductListDisplaysData() throws {
        
        let collectionView = app.collectionViews["collectionViewProducts"]

        XCTAssert(collectionView.waitForExistence(timeout: 2))
        XCTAssertEqual(collectionView.cells.count, 3, "Product list should contain 3 elements")
    }
    
    func test_ProductDisplayeModallyWithProductNameAsNavigationTitle() throws {
        
        let collectionView = app.collectionViews["collectionViewProducts"]
        XCTAssert(collectionView.waitForExistence(timeout: 2))

        let cell = collectionView.children(matching: .cell).matching(identifier: "collectionCellProduct").element(boundBy: 1)
        
        cell.tap()
        
        XCTAssert(app.navigationBars["iPhone 9"].exists)
    }
}
