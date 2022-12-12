//
//  Requests_SetEnabledAnalytics.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 11.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_SetEnabledAnalytics: XCTestCase {
    let goodBackendId = "analytics"
    let badBackendId = "analytics_bad"

    func test_SetEnabledAnalyticsRequest() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        Tester.makeCreateProfileRequest(session, profileId: profileId) { success in
            XCTAssert(success, "Can't create profile")

            let request = UpdateProfileRequest(
                profileId: profileId,
                parameters: AdaptyProfileParameters.Builder()
                    .with(analyticsDisabled: false)
                    .build(),
                environmentMeta: Environment.Meta(includedAnalyticIds: true),
                responseHash: nil)

            session.perform(request) { (result: HTTPEmptyResponse.Result) in
                expectation.fulfill()
                HTTPAssertResponseSuccess(result, 200)
            }
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
