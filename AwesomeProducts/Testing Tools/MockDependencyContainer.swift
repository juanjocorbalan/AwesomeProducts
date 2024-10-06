import CoreData
import Data

final class MockDependencyContainer: DependencyContainer {
    lazy var mockConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return configuration
    }()
    
    private var selectedURLSessionConfiguration: URLSessionConfiguration = .default

    override func resolve() -> APIClient {
        let client = APIClient(configuration: selectedURLSessionConfiguration)
        return client
    }
    
    override func resolve() -> CoreDataStack {
        CoreDataStack(inMemory: true)
    }
}

extension MockDependencyContainer {
    func setUp() {
        selectedURLSessionConfiguration = mockConfiguration
        MockURLProtocol.addStub(with: "products.json", for: ProductsAPI.url.products)
    }
    
    func tearDown() {
        selectedURLSessionConfiguration = .default
        MockURLProtocol.removeStub()
    }
}
