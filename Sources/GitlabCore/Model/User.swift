//
//  User.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Foundation

public struct User: Entity {
    public enum State: String, Codable {
        case active
        case blocked
    }
    public let id: Int
    public var state: State
    public var username: String
    public var name: String?
    public var avatar_url: URL?
    public var web_url: URL?
}
