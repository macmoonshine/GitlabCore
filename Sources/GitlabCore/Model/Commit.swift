//
//  Commit.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Foundation

public struct Commit: Entity {
    public struct Info: Record {
        public let message: String?
        public let error_code: String?
        public let dry_run: String?
    }
    public let id: String
    public let short_id: String
    public let title: String
    public let author_name: String
    public let author_email: String
    public let created_at: Timestamp
    public let message: String
    public let parent_ids: [String]?
    public let web_url: URL
}
