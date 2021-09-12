//
//  Projects.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Combine

open class Projects: API<Project> {
    public init(gitlab: Gitlab) {
        super.init(gitlab: gitlab, basePath: "/projects")
    }
}

public extension Gitlab {
    var projects: Projects {
        return Projects(gitlab: self)
    }
}
