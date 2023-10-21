import Foundation
import Combine
import Domain

@MainActor
final class ProductCellViewModel {
    let id: Int

    // MARK: - Inputs
    let removeSelected = PassthroughSubject<Void, Never>()

    // MARK: - Outputs
    @Published private(set) var name: String
    @Published private(set) var city: String
    @Published private(set) var avatar: URL?
    @Published private(set) var background: URL?

    // MARK: - Init

    init(product: Product) {
        self.id = product.id
        self.name = product.title
        self.city =  product.brand
        self.avatar = product.thumbnail
        self.background = product.image
    }
}

extension ProductCellViewModel: Hashable {
    static func == (lhs: ProductCellViewModel, rhs: ProductCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
