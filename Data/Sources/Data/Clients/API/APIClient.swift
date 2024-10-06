import Foundation
import HTTPTypes
import HTTPTypesFoundation

enum APIError: Error {
    case serialization
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case http(String)
    case unknown(Error)
}

public protocol ResourceType {
    associatedtype ResponseType: Codable
    var url: URL { get set }
    var parameters: [String: String]? { get set }
    var method: HTTPRequest.Method { get }
    
    init(url: URL, parameters: [String: String]?, method: HTTPRequest.Method)
}

struct Resource<T: Codable>: ResourceType {
    typealias ResponseType = T
    public var url: URL
    public var parameters: [String: String]?
    public var method: HTTPRequest.Method
    
    public init(url: URL, parameters: [String: String]? = nil, method: HTTPRequest.Method) {
        self.url = url
        self.parameters = parameters
        self.method = method
    }
}

public protocol APIClientType: Sendable {
    func execute<R: ResourceType>(_ resource: R) async throws -> R.ResponseType
}

public struct APIClient: APIClientType {
    private let configuration: URLSessionConfiguration

    public init(configuration: URLSessionConfiguration = .default) {
        self.configuration = configuration
    }
    
    public func execute<R: ResourceType>(_ resource: R) async throws -> R.ResponseType {
        do {
            let data = try await request(resource)
            return try JSONDecoder().decode(R.ResponseType.self, from: data)
        } catch {
            if let _ = error as? DecodingError {
                throw APIError.serialization
            } else {
                throw error as? APIError ?? APIError.unknown(error)
            }
        }
    }
    
    // MARK: - Request
    
    private func request<R: ResourceType>(_ resource: R) async throws -> Data {
        var url = resource.url
        if let parametersJSON = resource.parameters {
            var components = URLComponents(string: resource.url.absoluteString)
            components?.queryItems = parametersJSON.map { URLQueryItem(name: $0.0, value: $0.1) }
            if let componentsUrl = components?.url {
                url = componentsUrl
            }
        }
        
        var request = HTTPRequest(method: resource.method, url: url)
        request.headerFields[.accept] = "application/json"
        request.headerFields[.contentType] = "application/json"
        
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        
        return try process(response: response, data: data)
    }
    
    private func process(response: HTTPResponse, data: Data) throws -> Data {
        switch response.status.code {
        case 200..<300:
            return data
        case 400:
            throw APIError.badRequest
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 500..<600:
            throw APIError.serverError
        default:
            throw APIError.http(response.debugDescription)
        }
    }
}
