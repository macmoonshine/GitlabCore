//
//  API.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Combine

open class API<T: Record> {
    public typealias Publisher = AnyPublisher<T, Error>
    public typealias ArrayPublisher = AnyPublisher<[T], Error>
    public typealias Parameters = Gitlab.Parameters

    public let gitlab: Gitlab
    public let basePath: String
    
    public init(gitlab: Gitlab, basePath: String) {
        self.gitlab = gitlab
        self.basePath = basePath
    }
    
    open func get(id: T.Id) -> Publisher where T: Entity {
        return gitlab.get(path: "\(basePath)/\(id)")
    }

    open func list(parameters: Gitlab.Parameters = [:]) -> ArrayPublisher {
        return gitlab.get(path: basePath, parameters: parameters)
    }
}
