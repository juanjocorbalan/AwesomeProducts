import XCTest
import Combine
import Data
@testable import AwesomeProducts

@MainActor
class ProductListViewModelTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    private let mockDependencyContainer = MockDependencyContainer()

    var sut: ProductListViewModel!
    
    override func setUp() async throws {
        sut = mockDependencyContainer.resolve(type: .active, parentFlow: nil)
    }
    
    func test_viewModel_shouldProvideTitle() {

        let expectation = XCTestExpectation(description: "ProductListViewModel should provide a title")
        
        sut.$title
            .sink(receiveValue: { title in
                XCTAssertEqual(title, "Awesome Products")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }

    func test_viewModel_shouldPovidesProductsOnReload() {
                
        let expectation = XCTestExpectation(description: "ProductListViewModel should provide products on reload")
        
        sut.$products
            .dropFirst()
            .sink(receiveValue: { products in
                XCTAssertEqual(products.count, 3, "3 ProductCellViewModel were exepcted but got \(products.count) instead")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        sut.reload.send(())
        
        wait(for: [expectation], timeout: 3.0)
    }

    func test_onProductSelection_viewModelShouldCallShowProduct() throws {
        
        let expectation = XCTestExpectation(description: "ProductListViewModel should call showProduct after product selection")
        
        sut.reload.send(())

        sut.productSelected
            .sink(receiveValue: { _ in
                expectation.fulfill()
            })
            .store(in: &cancellables)

        sut.productSelected.send("0")

        wait(for: [expectation], timeout: 3.0)
    }

    func test_onError_viewModelShouldProvideErrorMessageObservable() throws {
        
        let expectation = XCTestExpectation(description: "ProductListViewModel should provide an error message after an error occurs")
        
        MockURLProtocol.addErrorStub(for: ProductsAPI.url.products)
        
        var errorMessageReceived = false
        sut.$errorMessage
            .sink(receiveValue: { _ in
                errorMessageReceived = true
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        sut.reload.send(())
        
        wait(for: [expectation], timeout: 3.0)
        
        XCTAssertTrue(errorMessageReceived, "An error message should have been provided after failing reload data")
    }
    
    func test_viewModel_shouldProvideIsLoadingObservableInitiallyTrue() {

        let expectation = XCTestExpectation(description: "ProductListViewModel should provide is loading publisher and emit true initially")
        
        sut.$isLoading
            .sink(receiveValue: { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }

    func test_viewModel_shouldProvideIsLoadingObservableFalseAfterLoadingData() {

        let expectation = XCTestExpectation(description: "ProductListViewModel should provide is loading publisher and emit false after loading data")
        
        MockURLProtocol.addStub(with: "products.json", for: ProductsAPI.url.products)
        
        sut.reload.send(())

        sut.$isLoading.dropFirst()
            .sink(receiveValue: { value in
                XCTAssertFalse(value)
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 3.0)
    }

    func test_viewModel_shouldProvideIsLoadingObservableFalseAfterAnError() {

        let expectation = XCTestExpectation(description: "ProductListViewModel should provide is loading publisher and emit false after an error occurs")
        
        MockURLProtocol.addErrorStub(for: ProductsAPI.url.products)

        sut.reload.send(())

        sut.$isLoading.dropFirst(1)
            .sink(receiveValue: { value in
                XCTAssertFalse(value)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)
    }
}
