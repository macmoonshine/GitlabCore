//
//  Branch.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Foundation

public struct Branch: Record {
    public var name: String
    public var merged: Bool
    public var protected: Bool
    public var `default`: Bool
    public var developers_can_push: Bool
    public var developers_can_merge: Bool
    public var can_push: Bool
    public var web_url: URL
    public var commit: Commit
}
