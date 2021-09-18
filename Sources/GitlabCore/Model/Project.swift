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

public struct Project: Entity {
    public enum Visibility: String, Codable {
        case `private`
        case `internal`
        case `public`
    }
    public enum MergeMethod: String, Codable {
        case merge
        case rebase_merge
        case ff
    }
    
    public let id: Int
    public var path: String
    public var path_with_namespace: String
    public var description: String?
    public var visibility: Visibility
    public var owner: User?
    public var default_branch: String
    public var created_at: Timestamp
    public var merge_method: MergeMethod
    public var topics: [String]
    
    public static func id(for project: Any) -> CustomStringConvertible? {
        if let project = project as? Project {
            return project.id
        }
        else if let id = project as? Int {
            return id
        }
        else if let path = project as? String {
            return path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        }
        else {
            return nil
        }
    }
}
