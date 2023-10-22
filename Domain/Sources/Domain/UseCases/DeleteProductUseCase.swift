import Foundation

public class DeleteProductUseCase {
    private let repository: ProductsRepositoryType
    
    public init(repository: ProductsRepositoryType) {
        self.repository = repository
    }
    
    public func execute(with product: Product) async throws -> Void {
        try await repository.deleteProductBy(id: product.id.description)
    }
}
