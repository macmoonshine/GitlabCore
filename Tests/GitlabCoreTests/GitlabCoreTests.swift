    import XCTest
    @testable import GitlabCore

    final class GitlabCoreTests: XCTestCase {
        func list(users: [User]) {
            print(users)
        }
        func testExample() {
            if let gitlab = Gitlab("https://localhost/api/v4", token: "xxx") {
                let c = gitlab.projects.get(id: 312)
                    .flatMap {project -> Branches.Publisher in
                        print("project:", project)
                        return gitlab.branches(for: project).create(name: "newTestBranch", reference: "staging")
                    }
                    .sink(receiveCompletion: { print($0) }) {
                        print("branches:", $0)
                    }

                while true {
                    
                }
                c.cancel()
            }
        }
    }
