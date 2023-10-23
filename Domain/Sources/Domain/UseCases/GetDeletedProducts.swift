import Foundation

public class GetDeletedProductsUseCase: GetProductsUseCaseType {
    private let repository: ProductsRepositoryType
    
    public init(repository: ProductsRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Product] {
        try await repository.getDeletedProducts()
    }
}
