import XCTest
@testable import Domain

class GetProductsUseCaseTests: XCTestCase {
    private var repositoryMock: ProductsRepositoryMock!
    var sut: GetProductsUseCase!

    override func setUp() {
        super.setUp()
        repositoryMock = ProductsRepositoryMock()
        sut = GetProductsUseCase(repository: repositoryMock)
    }

    func test_getUsers_ShouldSucceed() async {
        let products = [Product.mock, Product.mock2]
        await repositoryMock.setProductResponse(.success(products))

        var result: [Product] = []

        do {
            result = try await sut.execute()
            XCTAssertFalse(result.isEmpty, "An array of Product objects was expected")
            XCTAssertEqual(result.count, 2, "2 products were expected as result but got \(result.count) instead")
            let called = await repositoryMock.getProductsCalled
            XCTAssertTrue(called, "`getProducts` should have been called")
        } catch {
            XCTFail("A valid resonse is expected by executing the use case")
        }
    }

    func test_getProductsOnBadResponse_ShouldFailWithError() async {
        await repositoryMock.setProductResponse(.failure(RepositoryError.error))

        var result: [Product] = []

        do {
            result = try await sut.execute()
            XCTFail("An error was expected due to a bad response but got '\(result)'")
        } catch {
        }
    }
}
