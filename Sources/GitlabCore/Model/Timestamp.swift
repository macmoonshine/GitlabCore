//
//  Timestamp.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Foundation

public struct Timestamp: Codable, CustomStringConvertible {
    private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    public let date: Date
    
    public init() {
        self.init(date: Date())
    }
    
    public init(date: Date) {
        self.date = date
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        if let date = Self.formatter.date(from: value) {
            self.date = date
        }
        else {
            throw CocoaError(.formatting)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(description)
    }
    
    public var description: String {
        return Self.formatter.string(from: date)
    }
}
