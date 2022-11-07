//
//  Requests+FetchAllProducts.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 11.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_FetchAllProducts: XCTestCase {
    let goodBackendId = "products"
    let badBackendId = "products_bad"

    func test_FetchAllProductsRequest_NoProfile() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchAllProductsRequest(profileId: profileId, responseHash: nil)

        session.perform(request) { (result: FetchAllProductsRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseSuccess(result, 200)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_FetchAllProductsRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = FetchAllProductsRequest(profileId: profileId, responseHash: nil)

        session.perform(request) { (result: FetchAllProductsRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseFailed(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
