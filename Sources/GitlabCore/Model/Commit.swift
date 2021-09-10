//
//  Commit.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Foundation

public struct Commit: Entity {
    private(set) public var id: String!
    private(set) public var short_id: String!
    public var title: String
    public var author_name: String
    public var author_email: String
    public var created_at: Timestamp
    public var message: String
    public var parent_ids: [String]?
    public var web_url: URL
}
