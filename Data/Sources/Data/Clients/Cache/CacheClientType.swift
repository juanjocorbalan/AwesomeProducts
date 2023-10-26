import Foundation

public protocol CacheClientType<T> {
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
