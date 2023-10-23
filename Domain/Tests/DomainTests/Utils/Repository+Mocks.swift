import Foundation
import Domain

enum RepositoryError: Error {
    case error
    case responseNotSet
}

final class ProductsRepositoryMock: ProductsRepositoryType {
    var products: [Product] = []
    var productsResponse: Result<[Product], RepositoryError>?
    var deletedProductsResponse: Result<[Product], RepositoryError>?
    var deleteResponse: Result<Void, RepositoryError>?
    var restoreResponse: Result<Void, RepositoryError>?
    var getProductsCalled = false
    var getDeletedProductsCalled = false
    var deleteProductCalled = false
    var restoreProductCalled = false

    func getProducts() async throws -> [Product] {
        getProductsCalled = true
        switch productsResponse {
        case .success(let products):
            return products
        case .failure(let error):
            throw error
        case .none:
            throw RepositoryError.responseNotSet
        }
    }
    
    func deleteProductBy(id: String) async throws {
        deleteProductCalled = true
        switch deleteResponse {
        case .success:
            break
        case .failure(let error):
            throw error
        case .none:
            throw RepositoryError.responseNotSet
        }
    }
    
    func getDeletedProducts() async throws -> [Product] {
        getDeletedProductsCalled = true
        switch deletedProductsResponse {
        case .success(let products):
            return products
        case .failure(let error):
            throw error
        case .none:
            throw RepositoryError.responseNotSet
        }
    }
    
    func restoreProductBy(id: String) async throws {
        restoreProductCalled = true
        switch restoreResponse {
        case .success:
            break
        case .failure(let error):
            throw error
        case .none:
            throw RepositoryError.responseNotSet
        }
    }
}
