import Foundation

public protocol GetProductsUseCaseType: Sendable {
    func execute() async throws -> [Product]
}

public final class GetProductsUseCase: GetProductsUseCaseType {
    private let repository: ProductsRepositoryType
    
    public init(repository: ProductsRepositoryType) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Product] {
        try await repository.getProducts()
    }
}
