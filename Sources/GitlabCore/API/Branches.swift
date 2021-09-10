//
//  Branches.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

public class Branches: API<Branch> {
    public let project: Project
    
    public init(gitlab: Gitlab, project: Project) {
        self.project = project
        super.init(gitlab: gitlab, basePath: "/projects/\(project.id ?? 0)/repository/branches")
    }
    
    public func create(name: String, reference: String) -> Publisher {
        let parameters: Parameters = [ "branch": name, "ref": reference ]
        
        return gitlab.send(path: basePath, parameters: parameters, method: "POST")
    }

    public func delete(name: String) -> Publisher {
        return gitlab.send(path: "\(basePath)/\(name)", method: "DELETE")
    }
}

public extension Gitlab {
    func branches(for project: Project) -> Branches {
        return Branches(gitlab: self, project: project)
    }
}
