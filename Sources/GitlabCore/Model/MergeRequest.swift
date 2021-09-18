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

public struct MergeRequest: Entity {
    public enum State: String, Codable {
        case opened
        case closed
        case locked
        case merged
    }
    public struct RebaseResponse: Record {
        private(set) public var rebase_in_progress: Bool
        private(set) public var merge_error: String?
    }
    
    private(set) public var id: Int
    private(set) public var iid: Int
    private(set) public var project_id: Int
    public var state: State
    public var title: String
    public var author: User
    public var created_at: Timestamp
    public var updated_at: Timestamp
    public var source_branch: String
    public var target_branch: String
    public var assignee: User?
    public var upvotes: Int
    public var downvotes: Int
}
