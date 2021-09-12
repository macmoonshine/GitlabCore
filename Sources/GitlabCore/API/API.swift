//
//  API.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Combine

open class API<T: Record> {
    public typealias Element = T
    public typealias Publisher = AnyPublisher<Element, Error>
    public typealias ArrayPublisher = AnyPublisher<[Element], Error>
    public typealias VoidPublisher = AnyPublisher<Void, Error>
    public typealias Parameters = Gitlab.Parameters

    public let gitlab: Gitlab
    public let basePath: String
    
    public init(gitlab: Gitlab, basePath: String) {
        self.gitlab = gitlab
        self.basePath = basePath
    }
    
    open func get(id: Element.Id) -> Publisher where Element: Entity {
        return gitlab.get(path: "\(basePath)/\(id)")
    }

    open func list(parameters: Gitlab.Parameters = [:]) -> ArrayPublisher {
        return gitlab.get(path: basePath, parameters: parameters)
    }
    
    open func fail<T>(_ error: Error) -> AnyPublisher<T, Swift.Error> {
        return Fail(outputType: T.self, failure: error)
            .eraseToAnyPublisher()
    }
}
