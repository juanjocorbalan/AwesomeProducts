import Foundation
import Domain
import HTTPTypes

public protocol ProductsAPIDataSourceType {
    func getProducts() async throws -> [Product]
}

public class ProductsAPIDataSource: ProductsAPIDataSourceType {
    private let apiClient: APIClient
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func getProducts() async throws -> [Product] {
        
        let url = ProductsAPI.baseURL.appendingPathComponent(ProductsAPI.paths.products)
        
        let resource = Resource<ProductsDTO>(url: url, parameters: nil, method: .get)
        
        return try await apiClient.execute(resource).products.toDomain()
    }
}
