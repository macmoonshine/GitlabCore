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

import Combine

public class Commits: API<Commit> {
    public enum Result: Codable {
        case commit(_: Commit)
        case info(_: Commit.Info)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let commit = try? container.decode(Commit.self) {
                self = .commit(commit)
            }
            else {
                self = .info(try container.decode(Commit.Info.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
            case .commit(let commit):
                try container.encode(commit)
            case .info(let info):
                try container.encode(info)
            }
        }
    }
    public typealias ResultPublisher = AnyPublisher<Result, Swift.Error>

    public let project: Project
    
    public init(gitlab: Gitlab, project: Project) {
        self.project = project
        super.init(gitlab: gitlab, basePath: "/projects/\(project.id)/repository/commits")
    }
    
    /**
     cherry picks the given commit into the given branch.
     - Parameter commit: the sha of the commit to cherry-pick.
     - Parameter branch: the name of the branch
     - Parameter dryRun: specifies whether the operation should be simulated only (`true`) or executed (`false`).
     - Parameter message: the commit message
     */
    public func cherryPick(commit: String, into branch: String,
                           dryRun: Bool = false, message: String? = nil
    ) -> ResultPublisher {
        let path = "/projects/\(project.id)/repository/commits/\(commit)/cherry_pick"
        var parameters: Parameters = [ "branch": branch, "dry_run": dryRun ]
        
        if let message = message {
            parameters["message"] = message
        }
        return gitlab.send(path: path, parameters: parameters, method: "POST")
    }

    /**
     cherry picks the given commit into the given branch.
     - Parameter commit: the commit to cherry-pick.
     - Parameter branch: the name of the branch
     - Parameter dryRun: specifies whether the operation should be simulated only (`true`) or executed (`false`).
     - Parameter message: the commit message
     */
    public func cherryPick(commit: Commit, into branch: Branch,
                           dryRun: Bool = false, message: String? = nil
    ) -> ResultPublisher {
        return cherryPick(commit: commit.id, into: branch.name, dryRun: dryRun,
                          message: message)
    }

    
    /**
     reverts the given commit from the given branch.
     - Parameter commit: the sha of the commit to cherry-pick.
     - Parameter branch: the name of the branch
     - Parameter dryRun: specifies whether the operation should be simulated only (`true`) or executed (`false`).
     */
    public func revert(
        commit: String, from branch: String, dryRun: Bool = false
    ) -> ResultPublisher {
        let path = "/projects/\(project.id)/repository/commits/\(commit)/revert"
        let parameters: Parameters = [ "branch": branch, "dry_run": dryRun ]
        
        return gitlab.send(path: path, parameters: parameters, method: "POST")
    }
    
    /**
     reverts the given commit from the given branch.
     - Parameter commit: the commit to revert
     - Parameter branch: the name of the branch
     - Parameter dryRun: specifies whether the operation should be simulated only (`true`) or executed (`false`).
     - Parameter message: the commit message
     */
    public func revert(
        commit: Commit, from branch: Branch, dryRun: Bool = false
    ) -> ResultPublisher {
        return revert(commit: commit.id, from: branch.name, dryRun: dryRun)
    }
}

public extension Gitlab {
    /// construct an api for accessing and modifying the commits of the given project.
    func commits(for project: Project) -> Commits {
        return Commits(gitlab: self, project: project)
    }
}
