import Domain
import CoreData

public protocol CacheClientType<T>: Sendable {
    associatedtype T: DomainToManagedConvertible

    func getAll() async throws -> [T]
    func get<V>(where key: String, equals value: V) async throws -> [T]
    func createOrUpdate(element: T) async throws -> Void
    func update<V>(where key: String, equals value: V, with values: [String: Any]) async throws -> Void
    func delete<V>(where key: String, equals value: V) async throws -> Void
    func deleteAll() async throws -> Void
}

public enum CacheError: Error {
    case fetchError
    case saving
}

public struct CoreDataClient<T: DomainToManagedConvertible>: CacheClientType {
    private var stack: CoreDataStack

    public init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }

    //MARK: - Get

    public func getAll() async throws -> [T] {
        do {
            let context = stack.backgroundContext
            return try await context.perform {
                let request = T.ManagedEntity.fetchRequest() as! NSFetchRequest<T.ManagedEntity>
                return try context.fetch(request).toDomain()
            }
        } catch {
            throw CacheError.fetchError
        }
    }

    public func get<V>(where key: String, equals value: V) async throws -> [T] {
        do {
            let context = stack.backgroundContext
            return try await context.perform {
                let request = T.ManagedEntity.fetchRequest() as! NSFetchRequest<T.ManagedEntity>
                request.predicate = NSPredicate(format: "\(key) == %@", argumentArray: [value])
                return try context.fetch(request).toDomain()
            }
        } catch {
            throw CacheError.fetchError
        }
    }

    // MARK: - Create/Update

    public func createOrUpdate(element: T) async throws -> Void {
        let context = stack.backgroundContext
        try await context.perform {
            let request = T.ManagedEntity.fetchRequest() as! NSFetchRequest<T.ManagedEntity>
            request.predicate = NSPredicate(format: "id == %@", argumentArray: [element.id])

            do {
                if let object = try context.fetch(request).first {
                    object.update(with: element)
                } else {
                    element.toManaged(in: context)
                }
            } catch {
                throw CacheError.fetchError
            }

            try context.saveIfNeeded()
        }
    }

    // MARK: - Partial Update

    public func update<V>(where key: String, equals value: V, with values: [String: Any]) async throws -> Void {
        let context = stack.backgroundContext
        try await context.perform {
            let request = T.ManagedEntity.fetchRequest() as! NSFetchRequest<T.ManagedEntity>
            request.predicate = NSPredicate(format: "\(key) == %@", argumentArray: [value])

            do {
                if let object = try context.fetch(request).first {
                    values.forEach { (key, value) in
                        object.setValue(value, forKey: key)
                    }
                }
            } catch {
                throw CacheError.fetchError
            }

            try context.saveIfNeeded()
        }
    }

    // MARK: - Remove

    public func delete<V>(where key: String, equals value: V) async throws -> Void {
        let context = stack.backgroundContext
        try await context.perform {
            let request = T.ManagedEntity.fetchRequest() as! NSFetchRequest<T.ManagedEntity>
            request.predicate = NSPredicate(format: "\(key) == %@", argumentArray: [value])

            do {
                if let object = try context.fetch(request).first {
                    context.delete(object)
                }
            } catch {
                throw CacheError.fetchError
            }

            try context.saveIfNeeded()
        }
    }

    public func deleteAll() async throws -> Void {
        let context = stack.backgroundContext
        try await context.perform {
            let request = T.ManagedEntity.fetchRequest() as! NSFetchRequest<T.ManagedEntity>

            do {
                let results = try context.fetch(request)

                results.forEach {
                    context.delete($0)
                }
            } catch {
                throw CacheError.fetchError
            }

            try context.saveIfNeeded()
        }
    }
}

extension NSManagedObjectContext {
    @discardableResult public func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        do {
            try save()
        } catch {
            throw CacheError.saving
        }
        return true
    }
}
