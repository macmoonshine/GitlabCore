import Foundation
import Combine

open class Gitlab {
    public enum Error: Swift.Error {
        case invalidURL
    }
    public typealias Parameters = [String:CustomStringConvertible]
    
    public static let defaultScheme = "https"
    
    private let components: URLComponents
    private let token: String
    private(set) public var session: URLSession
    private(set) public var queue: DispatchQueue? = nil
    private(set) public var retryCount: Int = 0
    
    public var url: URL {
        return components.url!
    }
    
    public required init(components: URLComponents, token: String, session: URLSession) {
        assert(components.url != nil)
        self.components = components
        self.token = token
        self.session = session
    }
    
    public convenience init?(url: URL, token: String) {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           components.url != nil {
            self.init(components: components, token: token, session: .shared)
        }
        else {
            return nil
        }
    }
    public convenience init?(_ url: String, token: String) {
        if let components = URLComponents(string: url), components.url != nil {
            self.init(components: components, token: token, session: .shared)
        }
        else {
            return nil
        }
    }
    
    open func copy() -> Self {
        return .init(components: components, token: token, session: session)
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
                      parameters: Parameters,
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

    open func send<T>(request: URLRequest) -> AnyPublisher<T, Swift.Error> where T: Decodable {
        let publisher = session.dataTaskPublisher(for: request)
            .retry(retryCount)
            .tryMap {output -> Data in
                if let response = output.response as? HTTPURLResponse,
                   response.statusCode >= 200 && response.statusCode < 300 {
                    return output.data
                }
                else {
                    throw URLError(.badServerResponse)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
        
        if let queue = queue {
            return publisher.receive(on: queue)
                .eraseToAnyPublisher()
        }
        else {
            return publisher
                .eraseToAnyPublisher()
        }
    }
    
    open func use(session: URLSession) -> Self {
        let gitlab = copy()
        
        gitlab.session = session
        return gitlab
    }
    
    open func retries(count: Int) -> Self {
        let gitlab = copy()
        
        gitlab.retryCount = count
        return gitlab
    }
    
    open func process(on: DispatchQueue) -> Self {
        let gitlab = copy()
        
        gitlab.queue = queue
        return gitlab
    }
}
