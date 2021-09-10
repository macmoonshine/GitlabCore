//
//  Commits.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

public class Commits: API<Commit> {
    public let project: Project
    
    public init(gitlab: Gitlab, project: Project) {
        self.project = project
        super.init(gitlab: gitlab, basePath: "/projects/\(project.id ?? 0)/repository/commits")
    }
}

public extension Gitlab {
    func commits(for project: Project) -> Commits {
        return Commits(gitlab: self, project: project)
    }
}
