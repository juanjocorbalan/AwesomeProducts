import Foundation
import CoreData

public class CoreDataStack {

    public static let shared: CoreDataStack = CoreDataStack()

    public let container: NSPersistentContainer

    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    public init(modelName: String = "AwesomeProducts", inMemory: Bool = false) {
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd"),
              let objectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unresolved opening NSManagedObjectModel")
        }
        self.container = NSPersistentContainer(name: modelName, managedObjectModel: objectModel)

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
}
