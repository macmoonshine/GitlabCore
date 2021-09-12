//
//  Entity.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

public protocol Entity: Record {
    associatedtype Id: Codable
    
    var id: Id { get }
}
