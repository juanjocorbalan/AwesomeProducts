import Domain
import CoreData

extension CDProduct: ManagedToDomainConvertible {
    public func update(with object: Product) {
        title = object.title
        text = object.description
        brand = object.brand
        category = object.category
        thumbnail = object.thumbnail?.absoluteString
        image = object.image?.absoluteString
    }
    
    public func toDomain() -> Product {
        return Product(id: id ?? "",
                       title: title ?? "",
                       description: text ?? "",
                       brand: brand ?? "",
                       category: category ?? "",
                       thumbnail: URL(string: thumbnail ?? ""),
                       image: URL(string: image ?? ""),
                       isRemoved: isRemoved)
    }
}

extension Product: DomainToManagedConvertible {
    public func toManaged(in context: NSManagedObjectContext) -> CDProduct {
        let product = CDProduct(context: context)
        product.id = id
        product.title = title
        product.text = description
        product.brand = brand
        product.category = category
        product.thumbnail = thumbnail?.absoluteString
        product.image = image?.absoluteString
        product.isRemoved = isRemoved
        return product
    }
}

