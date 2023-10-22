import Domain
import CoreData

extension CDProduct: ManagedToDomainConvertibleEntity {
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
                       image: URL(string: image ?? ""))
    }
}

extension Product: DomainToManagedConvertibleEntity {
    public func toManaged(in context: NSManagedObjectContext) -> CDProduct {
        let product = CDProduct(context: context)
        product.id = id
        product.title = title
        product.text = description
        product.brand = brand
        product.category = category
        product.thumbnail = thumbnail?.absoluteString
        product.image = image?.absoluteString
        return product
    }
}

