import Foundation

public struct Product: Codable, Identifiable, Sendable {
    public let id: String
    public var title: String
    public var description: String
    public var brand: String
    public var category: String
    public var thumbnail: URL?
    public var image: URL?
    public var isRemoved: Bool
    
    public init(
        id: String,
        title: String,
        description: String,
        brand: String,
        category: String,
        thumbnail: URL?,
        image: URL?,
        isRemoved: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.brand = brand
        self.category = category
        self.thumbnail = thumbnail
        self.image = image
        self.isRemoved = isRemoved
    }
}


#if DEBUG
public extension Product {
    static let mock = Product(
        id: "1",
        title: "iPhone 15",
        description: "iPhone 15 is the best iPhone ever made.",
        brand: "Apple",
        category: "Smartphones",
        thumbnail: URL(string: "https://i.dummyjson.com/data/products/9/thumbnail.jpg")!,
        image: URL(string: "https://i.dummyjson.com/data/products/9/2.png")!,
        isRemoved: false
    )
    
    static let mock2 = Product(
        id: "2",
        title: "iPhone 15 Pro Max",
        description: "iPhone 15 Pro is the first iPhone to feature an aerospace‑grade titanium design, using the same alloy that spacecraft use for missions to Mars.",
        brand: "Apple",
        category: "Smartphones",
        thumbnail: URL(string: "https://i.dummyjson.com/data/products/3/thumbnail.jpg")!,
        image: URL(string: "https://i.dummyjson.com/data/products/3/2.png")!,
        isRemoved: false
    )
}
#endif
