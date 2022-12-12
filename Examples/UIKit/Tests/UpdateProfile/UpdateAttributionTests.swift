//
//  UpdateAttributionTests.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 27.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class UpdateAttributionTests: XCTestCase {
    func test_Activate() {
        let env = AdaptyEnvironment.production
        
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        
        Adapty.activate(env.apiKey)
        
        let attribution: [AnyHashable: Any] = ["+is_first_session": 0,
                                               "+clicked_branch_link": 0]
        
        Adapty.updateAttribution(attribution, source: .branch) { error in
            expectation.fulfill()
            XCTAssertNil(error)
        }
        
        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
    
    func test_Appsflyer() {
        let networkUserId = "1666881898163-0409554"
        let attribution: [AnyHashable: Any] = ["is_first_launch": 1,
                                               "af_status": "Organic",
                                               "install_time": "2022-10-27 15:11:51.771",
                                               "af_message": "organic install"]
        
        let (_, session) = Tester.createBackendAndSession(id: "attribution")
        let profileId = TestsConstants.existingProfileId

        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        session.performSetAttributionRequest(profileId: profileId,
                                             networkUserId: networkUserId,
                                             source: .appsflyer,
                                             attribution: attribution) { error in
            expectation.fulfill()
            XCTAssertNil(error)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
    
    func test_Branch() {
        let attribution: [AnyHashable: Any] = ["+is_first_session": 0,
                                               "+clicked_branch_link": 0]
        
        let (_, session) = Tester.createBackendAndSession(id: "attribution")
        let profileId = TestsConstants.existingProfileId

        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        session.performSetAttributionRequest(profileId: profileId,
                                             networkUserId: nil,
                                             source: .branch,
                                             attribution: attribution) { error in
            expectation.fulfill()
            XCTAssertNil(error)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
