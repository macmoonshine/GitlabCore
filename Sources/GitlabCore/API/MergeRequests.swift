//
//  MergeRequests.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

import Foundation
import Combine

public class MergeRequests: API<MergeRequest> {
    public typealias RebaseResponsePublisher = AnyPublisher<MergeRequest.RebaseResponse, Swift.Error>
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
    
    open func create(source: String, target: String, title: String,
                     _ parameters: Parameters = [:]) -> Publisher {
        var parameters = parameters
        var path = basePath
        
        if let value = parameters.removeValue(forKey: "id"),
           let id = Project.id(for: value) {
            path = "/projects/\(id)/merge_requests"
        }
        parameters["source_branch"] = source
        parameters["target_branch"] = target
        parameters["title"] = title
        return gitlab.send(path: path, parameters: parameters, method: "POST")
    }
    
    open func update(mergeRequest: MergeRequest, _ parameters: Parameters) -> Publisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)"
        
        return gitlab.send(path: path, parameters: parameters, method: "PUT")
    }

    open func rebase(mergeRequest: MergeRequest, skipCI: Bool) -> RebaseResponsePublisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)/rebase"
        
        return gitlab.send(path: path, method: "PUT")
    }
    
    open func accept(mergeRequest: MergeRequest, _ parameters: Parameters = [:]) -> Publisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)/merge"
        
        return gitlab.send(path: path, parameters: parameters, method: "PUT")
    }
    
    open func delete(mergeRequest: MergeRequest) -> VoidPublisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)"
        
        return gitlab.send(path: path, method: "DELETE")
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
