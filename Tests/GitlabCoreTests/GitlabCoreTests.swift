    import XCTest
    import Combine
    @testable import GitlabCore
    
    final class GitlabCoreTests: XCTestCase {
        let gitlab = Gitlab("https://gitlab.com/api/v4", token: "xxx")!
        var running = true
        
        public override func setUp() {
            running = true
        }
        
        func testListProjects() {
            let c = gitlab.projects.list(parameters: [ "owned": true ])
                .sink(receiveCompletion: { print($0) }) {
                    print($0)
                    self.running = false
                }
            
            while running {
            }
            c.cancel()
        }
        
        func testCreateBranch() {
            let c = gitlab.projects.get(id: 29534978)
                .flatMap {project -> Branches.Publisher in
                    print("project:", project)
                    return self.gitlab.branches(for: project)
                        .create(name: "newTestBranch", reference: "main")
                }
                .sink(receiveCompletion: { print($0) }) {
                    print("branches:", $0)
                    self.running = false
                }
            
            while running {
            }
            c.cancel()
        }
        
        func testCreateMergeRequest() {
            let c = gitlab.projects.list(parameters: [ "owned": true , "search": "test"])
                .flatMap { projects -> MergeRequests.Publisher in
                    print("create")
                    return self.gitlab.mergeRequests(for: projects[0])
                        .create(source: "main", target: "staging", title: "Merge main to staging")
                }
                .flatMap { mergeRequest -> MergeRequests.RebaseResponsePublisher in
                    print("rebase")
                    return self.gitlab.mergeRequests
                        .rebase(mergeRequest: mergeRequest, skipCI: true)
                }
                .sink(receiveCompletion: { print($0) }) {
                    print($0)
                    self.running = false
                }
            
            while running {
            }
            c.cancel()
        }
        func testAcceptMergeRequest() {
            let c = gitlab.projects.list(parameters: [ "owned": true , "search": "test"])
                .flatMap { projects -> MergeRequests.Publisher in
                    return self.gitlab.mergeRequests(for: projects[0])
                        .get(id: 5)
                }
                .flatMap { mergeRequest -> MergeRequests.Publisher in
                    print("merge")
                    return self.gitlab.mergeRequests
                        .accept(mergeRequest: mergeRequest)
                }
                .sink(receiveCompletion: { print($0) }) {
                    print($0)
                    self.running = false
                }
            
            while running {
            }
            c.cancel()
        }
        
        func testDeleteMergeRequest() {
            let c = gitlab.projects.list(parameters: [ "owned": true , "search": "test"])
                .flatMap { projects -> MergeRequests.Publisher in
                    return self.gitlab.mergeRequests(for: projects[0])
                        .get(id: 7)
                }
                .flatMap { mergeRequest -> AnyPublisher<Void, Swift.Error> in
                    print("merge")
                    return self.gitlab.mergeRequests
                        .delete(mergeRequest: mergeRequest)
                }
                .sink(receiveCompletion: { print($0) }) {
                    print($0)
                    self.running = false
                }
            
            while running {
            }
            c.cancel()
        }
    }
