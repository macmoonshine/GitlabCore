//
//  Users.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

open class Users: API<User> {
    public init(gitlab: Gitlab) {
        super.init(gitlab: gitlab, basePath: "/users")
    }
}

public extension Gitlab {
    var users: Users {
        return Users(gitlab: self)
    }
}
