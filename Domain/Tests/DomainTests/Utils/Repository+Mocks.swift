import Foundation
import Domain

enum RepositoryError: Error {
    case error
    case responseNotSet
}

final class ProductsRepositoryMock: ProductsRepositoryType {

    var products: [Product] = []
    var productsResponse: Result<[Product], RepositoryError>?
    var deleteResponse: Result<Void, RepositoryError>?
    var getProductsCalled = false
    var deleteProductCalled = false

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
}
