//
//  Requests+SetAttribution.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 12.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_SetAttribution: XCTestCase {
    let goodBackendId = "attribution"
    let badBackendId = "attribution_bad"

    func test_SetAttributionRequest_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let networkUserId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = SetAttributionRequest(profileId: profileId, networkUserId: networkUserId, source: .custom, attribution: ["key1": "value1"])

        session.perform(request) { (result: SetAttributionRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseSuccess(result, 200)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_SetAttributionRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let networkUserId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = SetAttributionRequest(profileId: profileId, networkUserId: networkUserId, source: .custom, attribution: ["key1": "value1"])

        session.perform(request) { (result: SetAttributionRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
