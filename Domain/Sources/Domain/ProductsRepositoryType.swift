import Foundation

public protocol ProductsRepositoryType {
    func getProducts() async throws -> [Product]
    func deleteProductBy(id: String) async throws -> Void
}
