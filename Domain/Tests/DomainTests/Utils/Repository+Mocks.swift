import Foundation
import Domain

enum RepositoryError: Error {
    case error
    case responseNotSet
}

final actor ProductsRepositoryMock: ProductsRepositoryType {
    private(set) var productsResponse: Result<[Product], RepositoryError>?
    private(set) var deletedProductsResponse: Result<[Product], RepositoryError>?
    private(set) var deleteResponse: Result<Void, RepositoryError>?
    private(set) var restoreResponse: Result<Void, RepositoryError>?
    private(set) var getProductsCalled = false
    private(set) var getDeletedProductsCalled = false
    private(set) var deleteProductCalled = false
    private(set) var restoreProductCalled = false

    func setProductResponse(_ response: Result<[Product], RepositoryError>?) {
        productsResponse = response
    }

    func setDeletedProductsResponse(_ response: Result<[Product], RepositoryError>?) {
        deletedProductsResponse = response
    }

    func setDeleteResponse(_ response: Result<Void, RepositoryError>?) {
        deleteResponse = response
    }

    func setRestoreResponse(_ response: Result<Void, RepositoryError>?) {
        restoreResponse = response
    }

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
