import Foundation

public class GetProductsUseCase {
    private let repository: ProductsRepositoryType
    
    public init(repository: ProductsRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Product] {
        try await repository.getProducts()
    }
}
