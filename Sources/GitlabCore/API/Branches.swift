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

public class Branches: API<Branch> {
    public let project: Project
    
    /**
     creates an api to access and modify branches of the given project.
     - Parameter project: a project in Gitlab
     */
    public init(gitlab: Gitlab, project: Project) {
        self.project = project
        super.init(gitlab: gitlab, basePath: "/projects/\(project.id)/repository/branches")
    }
    
    /**
     create a branch.
     - Parameter name: the name for the new branch.
     - Parameter reference: the branch name or the commit sha to create the branch from
     */
    open func create(name: String, reference: String) -> Publisher {
        let parameters: Parameters = [ "branch": name, "ref": reference ]
        
        return gitlab.send(path: basePath, parameters: parameters, method: "POST")
    }

    /**
     delete the branch with the given name.
     - Parameter name: the name of the branch.
     */
    open func delete(name: String) -> Publisher {
        return gitlab.send(path: "\(basePath)/\(name)", method: "DELETE")
    }
    
    /**
     deletes all merged branches
     */
    open func deleteMerged() -> VoidPublisher {
        return gitlab.send(path: "/projects/\(project.id)/repository/merged_branches", method: "DELETE")
    }
}

public extension Gitlab {
    /// construct an api for accessing and modifying the branches of the given project.
    func branches(for project: Project) -> Branches {
        return Branches(gitlab: self, project: project)
    }
}
