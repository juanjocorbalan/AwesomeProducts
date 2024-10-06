import XCTest
@testable import Data

class APIClientTests: XCTestCase {

    private let mockConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return configuration
    }()

    var resource = Resource<ProductsDTO>(url: ProductsAPI.url.products, parameters: nil,  method: .get)
    var sut: APIClient!
    
    override func setUp() {
        super.setUp()
        MockURLProtocol.removeStub()
        sut = APIClient(configuration: mockConfiguration)
    }
    
    func test_getProductsFromAPI_ShouldSucceed() async {

        MockURLProtocol.addStub(with: "products.json", for: resource.url)
        
        var result: ProductsDTO?
        
        do {
            result = try await sut.execute(resource)
            XCTAssertNotNil(result, "An object of type ProductsDTO objects was expected")
            XCTAssertTrue(result?.products.count == 3, "An array with 2 ProductDTO elements was expected")
        } catch {
            XCTFail("A valid resonse is expected by executing a valid resource")
        }
    }
    
    func test_getProductsWithBadResponse_ShouldFailWithError() async {
        
        MockURLProtocol.addErrorStub(for: resource.url)
        
        var result: ProductsDTO?
        
        do {
            result = try await sut.execute(resource)
            XCTFail("An error was expected on a bad response but got some result: `\(String(describing: result))`")
        } catch {
        }
    }
}
