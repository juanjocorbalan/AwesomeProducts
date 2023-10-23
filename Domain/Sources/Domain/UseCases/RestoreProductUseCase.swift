import Foundation

public class RestoreProductUseCase: RemoveFromListUseCaseType {
    private let repository: ProductsRepositoryType
    
    public init(repository: ProductsRepositoryType) {
        self.repository = repository
    }
    
    public func execute(with product: Product) async throws -> Void {
        try await repository.restoreProductBy(id: product.id.description)
    }
}
