//
//  MergeRequest.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

public struct MergeRequest: Entity {
    public enum State: String, Codable {
        case opened
        case closed
        case locked
        case merged
    }
    
    private(set) public var id: Int!
    private(set) public var iid: Int!
    private(set) public var project_id: Int!
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
