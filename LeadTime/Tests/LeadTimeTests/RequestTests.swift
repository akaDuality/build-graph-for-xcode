import XCTest
@testable import LeadTime

import OctoKit

final class RequestTests: XCTestCase {
    
    let config = TokenConfiguration("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")
    
    //            let config = TokenConfiguration("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", url: "https://github.dodopizza.com/api/v3/")
    
    func testUser() {
        let expectation = self.expectation(description: "response")
        
        Octokit(config).me() { response in
            switch response {
            case .success(let user):
                print(user.login as Any)
            case .failure(let error):
                print(error)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRepositories() {
        let expectation = self.expectation(description: "response")
        
        Octokit(config).repositories { repositories in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testRepository() {
        let expectation = self.expectation(description: "response")
        
        Octokit(config).repository(owner: "akaDuality", name: "BowlingKata") { repository in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testCommits() {
        let expectation = self.expectation(description: "response")
        
        Octokit(config).listCommits(owner: "akaDuality", repository: "BowlingKata") { commits in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testTags() {
        let expectation = self.expectation(description: "response")
        
        Octokit(config).tags(owner: "akaDuality", repository: "BowlingKata") { tags in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testReleases() {
        let expectation = self.expectation(description: "response")
        
        Octokit(config).listReleases(owner: "akaDuality", repository: "BowlingKata") { releseas in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}


