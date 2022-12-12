//
//  Requests+SetTransactionVariationId.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 11.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_SetTransactionVariationId: XCTestCase {
    let goodBackendId = "transaction_variation"
    let badBackendId = "transaction_variation_bad"

    // Не очень ясно, как протестировать, надо поискать валидную транзакци
    func test_SetTransactionVariationIdRequest() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let transactionId = UUID().uuidString.lowercased()
        let variationId = UUID().uuidString.lowercased()

        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        Tester.makeCreateProfileRequest(session, profileId: profileId) { success in
            XCTAssert(success, "Can't create profile")

            let request = SetTransactionVariationIdRequest(profileId: profileId,
                                                           transactionId: transactionId,
                                                           variationId: variationId)

            session.perform(request) { (result: SetTransactionVariationIdRequest.Result) in
                expectation.fulfill()
                HTTPAssertResponseFailed(result, 400)
            }
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_SetTransactionVariationIdRequest_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let transactionId = UUID().uuidString.lowercased()
        let variationId = UUID().uuidString.lowercased()

        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = SetTransactionVariationIdRequest(profileId: profileId,
                                                       transactionId: transactionId,
                                                       variationId: variationId)

        session.perform(request) { (result: SetTransactionVariationIdRequest.Result) in
            expectation.fulfill()
            HTTPAssertErrorBackendCodeEqual(result, 400)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_SetTransactionVariationIdRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let transactionId = UUID().uuidString.lowercased()
        let variationId = UUID().uuidString.lowercased()

        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = SetTransactionVariationIdRequest(profileId: profileId,
                                                       transactionId: transactionId,
                                                       variationId: variationId)

        session.perform(request) { (result: SetTransactionVariationIdRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
