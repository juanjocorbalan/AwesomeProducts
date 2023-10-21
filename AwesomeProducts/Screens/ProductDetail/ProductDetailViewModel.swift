import Foundation
import Combine
import Domain

@MainActor
final class ProductDetailViewModel {
    
    // MARK: - Inputs

    let close = PassthroughSubject<Void, Never>()

    // MARK: - Outputs
    
    @Published private(set) var name: String
    @Published private(set) var text: String
    @Published private(set) var brand: String
    @Published private(set) var category: String
    @Published private(set) var thumbnail: URL?
    @Published private(set) var background: URL?

    // MARK: - Init

    init(product: Product) {
        self.name = product.title
        self.text = product.description
        self.brand = product.brand
        self.category = product.category
        self.thumbnail = product.thumbnail
        self.background = product.image
    }
}
