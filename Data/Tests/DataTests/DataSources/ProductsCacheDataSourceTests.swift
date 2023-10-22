import XCTest
import Domain
@testable import Data

class ProductsCacheDataSourceTests: XCTestCase {
    private var mockCacheClient: CoreDataClient<Product>!
    var sut: ProductsCacheDataSource<CoreDataClient<Product>>!
    
    override func setUp() {
        super.setUp()
        mockCacheClient = CoreDataClient<Product>(coreDataStack: CoreDataStack(inMemory: true))
        sut = ProductsCacheDataSource(cacheClient: mockCacheClient)
    }
    
    func test_getObjectsFromEmptyCache_ShouldCompleteWithoutValue() async {
        var result: [Product] = []
        
        do {
            result = try await sut.getProducts(where: ProductCacheKeys.id, equals: "1")
            XCTAssertTrue(result.isEmpty, "Inexistent object shouldn't be found but got \(result.count) results instead")
        } catch {
            XCTFail("Shouldn't throw error. Should return an empty array instead")
        }
        
    }
    
    func test_insertObjectInCache_ShouldSucceed() async {
        do {
            try await sut.createOrUpdate(product: .mock)
        } catch {
            XCTFail("A valid object should have been inserted into cache but got an error instead")
        }
    }
    
    func test_getObjectInCacheByID_ShouldSucceed() async {
        do {
            try await sut.createOrUpdate(product: .mock)
        } catch {
            XCTFail("Error during test setup")
        }
        
        var result: [Product] = []
        
        do {
            result = try await sut.getProducts(where: ProductCacheKeys.id, equals: Product.mock.id)
            XCTAssertTrue(result.count == 1, "Existent object should be found")
        } catch {
            XCTFail("A valid object should have been found in cache but got an error")
        }
    }
    
    func test_getObjectsInCache_ShouldFindAsManyAsPreviouslyInserted() async {
        do {
            try await sut.createOrUpdate(product: .mock)
            try await sut.createOrUpdate(product: .mock2)
        } catch {
            XCTFail("Error during test setup")
        }
        
        var result: [Product] = []
        
        do {
            result = try await sut.getProducts(where: "brand", equals: "Apple")
            XCTAssertTrue(result.count == 2, "Two object were expected but got \(result.count) instead")
        } catch {
            XCTFail("Two valid objects should have been found in cache but got an error")
        }
        
    }
    
    func test_deleteObjectInCacheByID_ShouldSucceed() async {
        do {
            try await sut.createOrUpdate(product: .mock)
        } catch {
            XCTFail("Error during test setup")
        }
        
        do {
            try await sut.deleteProduct(id: Product.mock.id)
        } catch {
            XCTFail("Deleting an object should complete without error but got an error instead")
        }
    }
    
    func test_deletingObjectInCacheByID_ShouldPreventFindingItAgain() async {
        do {
            try await sut.createOrUpdate(product: .mock)
            try await sut.deleteProduct(id: Product.mock.id)
        } catch {
            XCTFail("Error during test setup")
        }
        
        var result: [Product] = []
        
        do {
            result = try await sut.getProducts(where: ProductCacheKeys.id, equals: "1")
            XCTAssertTrue(result.count == 0, "Deleted object shouldn't be found into cache but it was found")
        } catch {
            XCTFail("Should have complete a search with an empty array but got an error instead")
        }
    }
    
    func test_updatingAnObjectInCache_ShouldSucceed() async {
        do {
            try await sut.createOrUpdate(product: .mock)
        } catch {
            XCTFail("Error during test setup")
        }
        var updatedProduct = Product.mock
        updatedProduct.brand = "Samsung"
        
        do {
            try await sut.createOrUpdate(product: updatedProduct)
        } catch {
            XCTFail("Modifying an object into cache should complete without error")
        }
    }
    
    func test_modifyingAnObjectIntoCache_ShouldPersistChanges() async {
        do {
            try await sut.createOrUpdate(product: .mock)
        } catch {
            XCTFail("Error during test setup")
        }
        var updatedProduct = Product.mock
        updatedProduct.brand = "Samsung"
        
        do {
            try await sut.createOrUpdate(product: updatedProduct)
        } catch {
            XCTFail("Modifying an object into cache should complete without error")
        }
        
        var result: [Product] = []
        
        do {
            result = try await sut.getProducts(where: ProductCacheKeys.id, equals: updatedProduct.id)
            XCTAssertTrue(result.count == 1, "Only one updated object should be found in cache but got \(result.count) instead")
            XCTAssertTrue(result[0].brand == updatedProduct.brand, "'\(updatedProduct.brand)' was expcted as product brand but got '\(result[0].brand)' instead")
        } catch {
        }
    }
}
