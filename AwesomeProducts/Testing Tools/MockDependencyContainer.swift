import CoreData
import Combine
import Data

final class MockDependencyContainer: DependencyContainer {
    lazy var mockConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return configuration
    }()
    
    lazy var mockCoreDataStack: CoreDataStack = {
        CoreDataStack(inMemory: true)
    }()

    override func resolve() -> APIClient {
        let client = APIClient(configuration: mockConfiguration)
        MockURLProtocol.addStub(with: "products.json", for: ProductsAPI.url.products)
        return client
    }
    
    override func resolve() -> CoreDataStack {
        mockCoreDataStack
    }
}

let mockDependencyContainer = MockDependencyContainer()
