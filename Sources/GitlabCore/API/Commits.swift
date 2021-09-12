//
//  Commits.swift
//  
//
//  Created by Clemens Wagner on 10.09.21.
//

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
    
    public func cherryPick(commit: Commit, into branch: String,
                           dryRun: Bool = false, message: String? = nil
    ) -> ResultPublisher {
        let path = "/projects/\(project.id)/repository/commits/\(commit.id)/cherry_pick"
        var parameters: Parameters = [ "branch": branch, "dry_run": dryRun ]
        
        if let message = message {
            parameters["message"] = message
        }
        return gitlab.send(path: path, parameters: parameters, method: "POST")
    }

    public func revert(
        commit: Commit, into branch: String, dryRun: Bool = false
    ) -> ResultPublisher {
        let path = "/projects/\(project.id)/repository/commits/\(commit.id)/revert"
        let parameters: Parameters = [ "branch": branch, "dry_run": dryRun ]
        
        return gitlab.send(path: path, parameters: parameters, method: "POST")
    }
}

public extension Gitlab {
    func commits(for project: Project) -> Commits {
        return Commits(gitlab: self, project: project)
    }
}
