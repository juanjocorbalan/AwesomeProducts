import Foundation
import CoreData


public class CoreDataStack {
    public static let shared: CoreDataStack = CoreDataStack()
    
    public let container: NSPersistentContainer
    
    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    public init(modelName: String = "AwesomeProducts", inMemory: Bool = false) {
        do {
            self.container = try CoreDataStack.container(withModel: modelName)
        } catch {
            fatalError("Could not load managed object model with error: \(error)")
        }
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            self.container.persistentStoreDescriptions = [description]
        }
        
        self.container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    enum CoreDataError: Error {
        case modelNotFound(String)
        case modelLoadingFailed(URL)
    }
    
    private static var alreadyLoadedModel: NSManagedObjectModel?
    
    private static func loadModel(named: String) throws -> NSManagedObjectModel {
        if let alreadyLoadedModel { return alreadyLoadedModel }
        guard let modelURL = Bundle.module.url(forResource: named, withExtension: "momd") else {
            throw CoreDataError.modelNotFound(named)
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoreDataError.modelLoadingFailed(modelURL)
        }
        alreadyLoadedModel = model
        return model
    }
    
    private static func container(withModel name: String) throws -> NSPersistentContainer {
        let model = try loadModel(named: name)
        return NSPersistentContainer(name: name, managedObjectModel: model)
    }
}
