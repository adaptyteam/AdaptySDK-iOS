//
//  Requests+ValidateReceipt.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 12.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Requests_ValidateReceipt: XCTestCase {
    let goodBackendId = "validation"
    let badBackendId = "validation_bad"

    func test_ValidateReceiptRequest() throws {
        guard let receipt = Tester.getLatestReceipt() else {
            XCTFail("No receipt found!")
            return
        }

        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = ValidateReceiptRequest(profileId: profileId, receipt: receipt, purchaseProductInfo: nil)

        session.perform(request) { (result: ValidateReceiptRequest.Result) in
            expectation.fulfill()
            HTTPAssertResponseSuccess(result, 200)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_ValidateReceiptRequest_Corrupted() throws {
        let (_, session) = Tester.createBackendAndSession(id: goodBackendId)
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = ValidateReceiptRequest(profileId: profileId, receipt: "corrupted_receipt".data(using: .utf8)!, purchaseProductInfo: nil)

        session.perform(request) { (result: ValidateReceiptRequest.Result) in
            expectation.fulfill()
            HTTPAssertErrorBackendCodeEqual(result, 400)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_ValidateReceiptRequest_NoSecretKey() throws {
        let (_, session) = Tester.createBackendAndSession(id: badBackendId, secretKey: "wrong_key")
        let profileId = UUID().uuidString.lowercased()
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")

        let request = ValidateReceiptRequest(profileId: profileId, receipt: "corrupted_receipt".data(using: .utf8)!, purchaseProductInfo: nil)

        session.perform(request) { (result: ValidateReceiptRequest.Result) in
            expectation.fulfill()
            HTTPAssertErrorBackendCodeEqual(result, 401)
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
