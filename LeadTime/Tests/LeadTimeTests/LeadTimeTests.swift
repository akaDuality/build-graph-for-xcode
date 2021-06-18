import XCTest
@testable import LeadTime

final class LeadTimeTests: XCTestCase {
    
    let sut = LeadTime(owner: "akaDuality",
                       name: "BowlingKata",
                       token: "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")
    
    func testUser() {
        let expectation = self.expectation(description: "response")
        
        sut.fetchLeadTime(tag: "1.0") { response in
            switch response {
            case .success(let leadTime):
                print(leadTime)
            case .failure(let error):
                print(error)
            }
            expectation.fulfill()
        }
        
        
        wait(for: [expectation], timeout: 1)
    }
    
}


