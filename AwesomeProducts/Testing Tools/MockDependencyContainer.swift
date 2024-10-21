import CoreData
import Data

final class MockDependencyContainer: DependencyContainer {
    lazy var mockConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        defaultStubs()
        return configuration
    }()

    override func resolve() -> APIClientType {
        APIClient(configuration: mockConfiguration)
    }

    override func resolve() -> CoreDataStack {
        CoreDataStack(inMemory: true)
    }
}

extension MockDependencyContainer {
    func defaultStubs() {
        MockURLProtocol.addStub(with: "products.json", for: ProductsAPI.url.products)
    }

    func removeStubs() {
        MockURLProtocol.removeStub()
    }
}
