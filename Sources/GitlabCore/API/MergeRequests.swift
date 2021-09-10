//
//  MergeRequests.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

public class MergeRequests: API<MergeRequest> {
    public let project: Project?
    
    public init(gitlab: Gitlab, project: Project? = nil) {
        self.project = project
        if let id = project?.id {
            super.init(gitlab: gitlab, basePath: "/projects/\(id)/merge_requests")
        }
        else {
            super.init(gitlab: gitlab, basePath: "/merge_requests")
        }
    }
}

public extension Gitlab {
    var mergeRequests: MergeRequests {
        return MergeRequests(gitlab: self)
    }
    func mergeRequests(for project: Project) -> MergeRequests {
        return MergeRequests(gitlab: self, project: project)
    }
}
