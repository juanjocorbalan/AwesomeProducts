import Foundation

public class MockURLProtocol: URLProtocol {
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            return
        }
        
        do {
            let (response, data) = try handler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    public override func stopLoading() {
    }
}

public extension MockURLProtocol {
    static func removeStub() {
        requestHandler = nil
    }
    
    static func addStub(with data: Data, for url: URL) {
        requestHandler = { request in
            let response = HTTPURLResponse(url: url,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, data)
        }
    }
    
    static func addStub(with jsonFile: String, for url: URL) {
        let data = Bundle.module.data(from: jsonFile)
        addStub(with: data, for: url)
    }

    static func addErrorStub(for url: URL) {
        requestHandler = { request in
            let response = HTTPURLResponse(url: url,
                                           statusCode: 400,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, nil)
          }
    }
}
