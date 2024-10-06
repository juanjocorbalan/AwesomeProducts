import Foundation

public protocol RemoveFromListUseCaseType: Sendable {
    func execute(with product: Product) async throws -> Void
}

public final class DeleteProductUseCase: RemoveFromListUseCaseType {
    private let repository: ProductsRepositoryType
    
    public init(repository: ProductsRepositoryType) {
        self.repository = repository
    }
    
    public func execute(with product: Product) async throws -> Void {
        try await repository.deleteProductBy(id: product.id)
    }
}
