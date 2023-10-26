import Foundation
import CoreData

public protocol ToDomainConvertible {
    associatedtype DomainEntity: Identifiable

    func toDomain() -> DomainEntity
}

public protocol ManagedToDomainConvertible: ToDomainConvertible where Self: NSManagedObject {
 
    func update(with object: DomainEntity)
}

public protocol DomainToManagedConvertible: Identifiable {
    associatedtype ManagedEntity: ManagedToDomainConvertible where Self == ManagedEntity.DomainEntity

    @discardableResult
    func toManaged(in: NSManagedObjectContext) -> ManagedEntity
}
