import XCTest
import Domain
@testable import Data

class CoreDataClientTests: XCTestCase {
    private var mockCoreDataStack: CoreDataStack!
    var sut: CoreDataClient<Product>!
    
    override func setUp() {
        super.setUp()
        mockCoreDataStack = CoreDataStack(inMemory: true)
        sut = CoreDataClient<Product>(coreDataStack: mockCoreDataStack)
    }
    
    func test_getObjectsWhileEmpty_ShouldCompleteWithoutValues() async throws {
        do {
            let results = try await sut.getAll()
            XCTAssertTrue(results.isEmpty, "Expecting 0 results but got \(results.count) results instead")
        } catch {
            XCTFail("Expecting 0 results but got an error instead")
        }
    }

    func test_createObject_ShouldSucceed() async throws {
        do {
            try await sut.createOrUpdate(element: .mock)
        } catch {
            XCTFail("Error during test setup")
        }

        do {
            let results = try await sut.get(where: ProductCacheKeys.id, equals: Product.mock.id)
            XCTAssertTrue(results.count == 1, "A valid object should have been inserted into core data storage")
        } catch {
            XCTFail("Expecting 1 product as result but got an error instead")
        }
    }

    func test_getInexistentObject_ShouldFail() async throws {
        do {
            let results = try await sut.get(where: ProductCacheKeys.id, equals: Product.mock2.id)
            XCTAssertTrue(results.count == 0, "An inexistent object shouldn't have been found")
        } catch {
            XCTFail("Expecting 0 products as result but got an error instead")
        }
    }

    func test_deleteObject_ShouldSucceedAndRemoveFromStorage() async throws {
        do {
            try await sut.createOrUpdate(element: Product.mock)
            try await sut.delete(where: ProductCacheKeys.id, equals: Product.mock.id)
        } catch {
            XCTFail("Error during test setup")
        }

        do {
            let results = try await sut.get(where: ProductCacheKeys.id, equals: Product.mock.id)
            XCTAssertTrue(results.count == 0, "A deleted object shouldn't have been found")
        } catch {
            XCTFail("Expecting 0 products as result but got an error instead")
        }
    }

    func test_deletingAllObject_ShouldEmptyStorage() async throws {
        do {
            try await sut.createOrUpdate(element: Product.mock)
            try await sut.createOrUpdate(element: Product.mock2)
            try await sut.deleteAll()
        } catch {
            XCTFail("Error during test setup")
        }

        do {
            let results = try await sut.getAll()
            XCTAssertTrue(results.count == 0, "After deleting all objects shouldn't have found any")
        } catch {
            XCTFail("Expecting 0 products as result but got an error instead")
        }
    }

    func test_updatingAnObject_ShouldSucceed() async throws {
        var updatedProduct = Product.mock

        do {
            try await sut.createOrUpdate(element: Product.mock)
            updatedProduct.brand = "Samsung"
            try await sut.createOrUpdate(element: updatedProduct)
        } catch {
            XCTFail("Error during test setup")
        }

        do {
            let results = try await sut.get(where: ProductCacheKeys.id, equals: Product.mock.id)
            XCTAssertTrue(results.first?.brand == updatedProduct.brand,
                          "The found object should have a modified property")
        } catch {
            XCTFail("Expecting a valid update operation but got an error instead")
        }
    }
}
