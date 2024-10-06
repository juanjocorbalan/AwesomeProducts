import Foundation
import Domain
import HTTPTypes

public protocol ProductsAPIDataSourceType: Sendable {
    func getProducts() async throws -> [Product]
}

public final class ProductsAPIDataSource: ProductsAPIDataSourceType {
    private let apiClient: APIClientType

    public init(apiClient: APIClientType) {
        self.apiClient = apiClient
    }
    
    public func getProducts() async throws -> [Product] {
        
        let url = ProductsAPI.baseURL.appendingPathComponent(ProductsAPI.paths.products)
        
        let resource = Resource<ProductsDTO>(url: url, parameters: nil, method: .get)
        
        return try await apiClient.execute(resource).products.toDomain()
    }
}
