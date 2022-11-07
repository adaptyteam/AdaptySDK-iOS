//
//  Requests+FetchPaywall.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 12.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_FetchPaywall: XCTestCase {
    let goodBackendId = "paywalls"
    let badBackendId = "paywalls_bad"

    func test_FetchPaywallRequest_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchPaywallRequest(paywallId: "example_ab_test", profileId: profileId, responseHash: nil)

        session.perform(request) { (result: FetchPaywallRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseSuccess(result, 200)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_FetchPaywallRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchPaywallRequest(paywallId: "example_ab_test", profileId: profileId, responseHash: nil)

        session.perform(request) { (result: FetchPaywallRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
