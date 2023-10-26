import Foundation
import Domain

public protocol ProductsCacheDataSourceType {
    func getProducts<V>(where key: String, equals value: V) async throws -> [Product]
    func createOrUpdate(product: Product) async throws -> Void
    func updateProduct(id: String, with values: [String : Any]) async throws -> Void
    func deleteProduct(id: String) async throws -> Void
    func restoreAllProducts() async throws -> Void
}

public class ProductsCacheDataSource<CacheClient: CacheClientType>: ProductsCacheDataSourceType where CacheClient.T == Product {
    
    private let cacheClient: CacheClient
    
    public init(cacheClient: CacheClient) {
        self.cacheClient = cacheClient
    }
    
    public func getProducts<V>(where key: String, equals value: V) async throws -> [Product] {
        try await cacheClient.get(where: key, equals: value)
    }
    
    public func createOrUpdate(product: Product) async throws -> Void {
        try await cacheClient.createOrUpdate(element: product)
    }
    
    public func updateProduct(id: String, with values: [String : Any]) async throws -> Void {
        try await cacheClient.update(where: ProductCacheKeys.id, equals: id, with: values)
    }
    
    public func deleteProduct(id: String) async throws -> Void {
        try await cacheClient.delete(where: ProductCacheKeys.id, equals: id)
    }
    
    public func restoreAllProducts() async throws -> Void {
        try await cacheClient.update(where: ProductCacheKeys.isRemoved, 
                                     equals: true,
                                     with: [ProductCacheKeys.isRemoved: false])
    }
}
