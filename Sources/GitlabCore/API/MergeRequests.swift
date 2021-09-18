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
import Combine

public class MergeRequests: API<MergeRequest> {
    public typealias RebaseResponsePublisher = AnyPublisher<MergeRequest.RebaseResponse, Swift.Error>
    public let project: Project?
    
    /**
     creates an api to access and modify the merge requests of the given project. If no project is given creation
     and fetching merge requests is not possible.
     */
    public init(gitlab: Gitlab, project: Project? = nil) {
        self.project = project
        if let id = project?.id {
            super.init(gitlab: gitlab, basePath: "/projects/\(id)/merge_requests")
        }
        else {
            super.init(gitlab: gitlab, basePath: "/merge_requests")
        }
    }
    
    /**
     creates a new merge request for merging `source` into `target`.
     */
    open func create(source: String, target: String, title: String,
                     _ parameters: Parameters = [:]) -> Publisher {
        var parameters = parameters
        
        if let value = parameters.removeValue(forKey: "id"),
           let id = Project.id(for: value) {
            let path = "/projects/\(id)/merge_requests"
            parameters["source_branch"] = source
            parameters["target_branch"] = target
            parameters["title"] = title
            return gitlab.send(path: path, parameters: parameters, method: "POST")
        }
        else {
            return fail(Gitlab.Error.parameterMissing(message: "No project given"))
        }
    }

    /**
     updates the properties of the given merge request.
     */
    open func update(mergeRequest: MergeRequest, _ parameters: Parameters) -> Publisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)"
        
        return gitlab.send(path: path, parameters: parameters, method: "PUT")
    }

    /**
     rebases the given merge request.
     */
    open func rebase(mergeRequest: MergeRequest, skipCI: Bool) -> RebaseResponsePublisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)/rebase"
        
        return gitlab.send(path: path, method: "PUT")
    }
    
    /**
     merges the given merge request into the target branch.
     */
    open func accept(mergeRequest: MergeRequest, _ parameters: Parameters = [:]) -> Publisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)/merge"
        
        return gitlab.send(path: path, parameters: parameters, method: "PUT")
    }
    
    /**
     deletes the given merge request.
     */
    open func delete(mergeRequest: MergeRequest) -> VoidPublisher {
        let path = "/projects/\(mergeRequest.project_id)/merge_requests/\(mergeRequest.iid)"
        
        return gitlab.send(path: path, method: "DELETE")
    }
}

public extension Gitlab {
    /**
     creates a new api for merge requests.
     */
    var mergeRequests: MergeRequests {
        return MergeRequests(gitlab: self)
    }
    /**
     creates a new api for merge requests in the given project.
     */
    func mergeRequests(for project: Project) -> MergeRequests {
        return MergeRequests(gitlab: self, project: project)
    }
}
