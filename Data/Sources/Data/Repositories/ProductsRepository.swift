import Foundation
import Domain

public final class ProductsRepository: ProductsRepositoryType {
    private let api: ProductsAPIDataSourceType
    private let cache: ProductsCacheDataSourceType
    
    public init(apiDataSource: ProductsAPIDataSourceType, cacheDataSource: ProductsCacheDataSourceType) {
        self.api = apiDataSource
        self.cache = cacheDataSource
    }
    
    public func getProducts() async throws -> [Product] {
        let products = try await api.getProducts()
        
        for product in products {
            try await cache.createOrUpdate(product: product)
        }

        return try await cache.getProducts(where: ProductCacheKeys.isRemoved, equals: false)
    }

    public func deleteProductBy(id: String) async throws -> Void {
        try await cache.updateProduct(id: id, with: [ProductCacheKeys.isRemoved : true])
    }
}
