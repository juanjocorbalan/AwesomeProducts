import Foundation
import Combine
import Domain

@MainActor
final class ProductCellViewModel: NSObject {
    let id: String

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
    
    override var hash: Int {
        return id.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? ProductCellViewModel {
            return self.id == other.id
        } else {
            return false
        }
    }
}
