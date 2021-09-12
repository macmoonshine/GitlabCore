import Foundation
import Combine

open class Gitlab {
    public enum Error: Swift.Error {
        case invalidURL
        case badResponse(statusCode: Int, message: String)
        case parameterMissing(message: String)
    }
    public typealias Parameters = [String:CustomStringConvertible]
 
    open class Decoder: JSONDecoder {
        open override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
            if type == Data.self, let data = data as? T {
                return data
            }
            else {
                return try super.decode(type, from: data)
            }
        }
    }
    
    public static let defaultScheme = "https"
    
    private let components: URLComponents
    private let token: String
    private(set) public var session: URLSession
    private(set) public var queue: DispatchQueue?
    private(set) public var retryCount: Int
    
    public var url: URL {
        return components.url!
    }
    
    public init(components: URLComponents, token: String) {
        assert(components.url != nil)
        self.components = components
        self.token = token
        self.session = .shared
        self.queue = nil
        self.retryCount = 0
    }
    
    public required init(from other: Gitlab) {
        self.components = other.components
        self.token = other.token
        self.session = other.session
        self.queue = other.queue
        self.retryCount = other.retryCount
    }
    
    public convenience init?(url: URL, token: String) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           components.url != nil {
            self.init(components: components, token: token)
        }
        else {
            return nil
        }
    }
    public convenience init?(_ url: String, token: String) {
        if let components = URLComponents(string: url), components.url != nil {
            self.init(components: components, token: token)
        }
        else {
            return nil
        }
    }
    
    open func url(for path: String, parameters: Parameters) -> URL? {
        var components = self.components
        
        components.path += path
        components.queryItems = parameters.map {
            return URLQueryItem(name: $0, value: $1.description)
        }
        return components.url
    }
    
    open func request(for path: String,
                        parameters: Parameters,
                        method: String = "GET",
                        body: Data? = nil
    ) -> URLRequest? {
        if let url = url(for: path, parameters: parameters) {
            var request = URLRequest(url: url)
            
            request.httpMethod = method
            request.httpBody = body
            request.setValue(token, forHTTPHeaderField: "PRIVATE-TOKEN")
            return request
        }
        else {
            return nil
        }
    }

    open func get<T>(
        path: String, parameters: Parameters = [:]
    ) -> AnyPublisher<T, Swift.Error> where T: Decodable {
        return send(path: path, parameters: parameters, method: "GET")
    }
    
    open func send<T>(path: String,
                      parameters: Parameters = [:],
                      method: String = "GET",
                      body: Data? = nil
    ) -> AnyPublisher<T, Swift.Error> where T: Decodable {
        if let request = self.request(for: path,
                                      parameters: parameters,
                                      method: method,
                                      body: body) {
            return send(request: request)
        }
        else {
            return Fail(outputType: T.self, failure: Error.invalidURL)
                .eraseToAnyPublisher()
        }
    }

    open func send(path: String,
                   parameters: Parameters = [:],
                   method: String = "GET",
                   body: Data? = nil
    ) -> AnyPublisher<Void, Swift.Error> {
        if let request = self.request(for: path,
                                      parameters: parameters,
                                      method: method,
                                      body: body) {
            return send(request: request)
        }
        else {
            return Fail(outputType: Void.self, failure: Error.invalidURL)
                .eraseToAnyPublisher()
        }
    }

    func message(for data: Data) -> String? {
        if let object = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]{
            return object["message"] as? String
        }
        else {
            return nil
        }
    }
    
    func _send(request: URLRequest) -> Publishers.TryMap<Publishers.Retry<URLSession.DataTaskPublisher>, Data> {
        return session.dataTaskPublisher(for: request)
            .retry(retryCount)
            .tryMap {output -> Data in
                if let response = output.response as? HTTPURLResponse {
                    if response.statusCode >= 200 && response.statusCode < 300 {
                        return output.data
                    }
                    else if let message = self.message(for: output.data) {
                        throw Error.badResponse(statusCode: response.statusCode, message: message)
                    }
                    else {
                        throw Error.badResponse(statusCode: response.statusCode,
                                                message: "Bad response")
                    }
                }
                else {
                    throw URLError(.badServerResponse)
                }
            }
    }
    
    open func send<T>(request: URLRequest) -> AnyPublisher<T, Swift.Error> where T: Decodable {
        let publisher = _send(request: request)
            .decode(type: T.self, decoder: Decoder())

        if let queue = queue {
            return publisher
                .receive(on: queue)
                .eraseToAnyPublisher()
        }
        else {
            return publisher
                .eraseToAnyPublisher()
        }
    }
    
    open func send(request: URLRequest) -> AnyPublisher<Void, Swift.Error> {
        let publisher = _send(request: request)
            .map {data -> Void in
                return ()
            }
        
        if let queue = queue {
            return publisher
                .receive(on: queue)
                .eraseToAnyPublisher()
        }
        else {
            return publisher
                .eraseToAnyPublisher()
        }
    }
    
    open func use(session: URLSession) -> Self {
        let gitlab = Self(from: self)
        
        gitlab.session = session
        return gitlab
    }
    
    open func retries(count: Int) -> Self {
        let gitlab = Self(from: self)

        gitlab.retryCount = count
        return gitlab
    }
    
    open func process(on: DispatchQueue) -> Self {
        let gitlab = Self(from: self)

        gitlab.queue = queue
        return gitlab
    }
}
