/*
 Copyright 2021 macoonshine
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Combine

/**
 defines basic operations for api access to the given model type. Many functions accect generic parameters of
 type `API.Parameters`. You can find a description of possible keys and values in the
 [Gitlab Rest API documentation](https://docs.gitlab.com/ee/api/api_resources.html).
 */
open class API<T: Record> {
    /// the type of the published objects
    public typealias Element = T
    /// a publisher when a single object is expected
    public typealias Publisher = AnyPublisher<Element, Error>
    /// a publisher when an array of objects is expected
    public typealias ArrayPublisher = AnyPublisher<[Element], Error>
    /// a publisher when no result or empty data is expected
    public typealias VoidPublisher = AnyPublisher<Void, Error>
    /// type for generic parameters
    public typealias Parameters = Gitlab.Parameters

    public let gitlab: Gitlab
    public let basePath: String
    
    public init(gitlab: Gitlab, basePath: String) {
        self.gitlab = gitlab
        self.basePath = basePath
    }
    
    /**
     fetches the object identified by the given id from the server.
     - Parameter id: the unique id of the object
     */
    open func get(id: Element.Id) -> Publisher where Element: Entity {
        return gitlab.get(path: "\(basePath)/\(id)")
    }

    /**
     list objects from the server.
     - Parameter parameters: defines filters for the search.
     */
    open func list(_ parameters: Gitlab.Parameters = [:]) -> ArrayPublisher {
        return gitlab.get(path: basePath, parameters: parameters)
    }
    
    open func fail<T>(_ error: Error) -> AnyPublisher<T, Swift.Error> {
        return Fail(outputType: T.self, failure: error)
            .eraseToAnyPublisher()
    }
}
