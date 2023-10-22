import Foundation
import CoreData

public protocol DomainConvertibleEntity {
    associatedtype DomainEntity

    func toDomain() -> DomainEntity
}

public protocol ManagedToDomainConvertibleEntity: DomainConvertibleEntity {
    func toDomain() -> DomainEntity
    func update(with object: DomainEntity)
}

public protocol DomainToManagedConvertibleEntity {
    associatedtype ManagedEntity: ManagedToDomainConvertibleEntity

    @discardableResult
    func toManaged(in: NSManagedObjectContext) -> ManagedEntity
}



