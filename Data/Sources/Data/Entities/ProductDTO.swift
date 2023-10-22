import Foundation
import Domain

struct ProductsDTO: Codable {
    let products: [ProductDTO]
}

struct ProductDTO: Codable {
    let id: Int
    let title: String
    let description: String
    let brand: String
    let category: String
    let thumbnail: String
    let images: [String]
}

extension ProductDTO: DomainConvertibleEntity {
    func toDomain() -> Product {
        return Product(id: String(id),
                       title: title,
                       description: description,
                       brand: brand,
                       category: category,
                       thumbnail: URL(string: thumbnail),
                       image: URL(string: images.first ?? ""))
    }
}
