//
//  Requests+SignSubscriptionOffer.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 12.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_SignSubscriptionOffer: XCTestCase {
    let goodBackendId = "subscription_offer"
    let badBackendId = "subscription_offer_bad"

    func test_SignSubscriptionOfferRequest_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = SignSubscriptionOfferRequest(vendorProductId: "weekly.premium.599", discountId: "123", profileId: profileId)

        session.perform(request) { (result: SignSubscriptionOfferRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseSuccess(result, 200)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_SignSubscriptionOfferRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = SignSubscriptionOfferRequest(vendorProductId: "weekly.premium.599", discountId: "123", profileId: profileId)

        session.perform(request) { (result: SignSubscriptionOfferRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
