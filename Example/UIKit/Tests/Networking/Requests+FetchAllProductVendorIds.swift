//
//  Requests+FetchAllProductVendorIds.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 14.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_FetchAllProductVendorIds: XCTestCase {
    let goodBackendId = "products_ids"
    let badBackendId = "products_ids_bad"

    func test_FetchAllProductsRequest_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchAllProductVendorIdsRequest(profileId: profileId, responseHash: nil)

        session.perform(request) { (result: FetchAllProductVendorIdsRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseSuccess(result, 200)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_FetchAllProductsRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchAllProductVendorIdsRequest(profileId: profileId, responseHash: nil)

        session.perform(request) { (result: FetchAllProductVendorIdsRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
