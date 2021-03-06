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

import Foundation

/**
 encapsulates dates for encoding and decoding.
 */
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
