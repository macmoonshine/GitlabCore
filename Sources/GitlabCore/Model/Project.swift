//
//  Project.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

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
    public var id: Int!
    public var path: String
    public var path_with_namespace: String
    public var description: String?
    public var visibility: Visibility
    public var owner: User?
    public var default_branch: String
    public var created_at: Timestamp
    public var merge_method: MergeMethod
    public var topics: [String]
}
