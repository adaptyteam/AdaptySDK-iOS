//
//  Models+Paywall.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 20.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import XCTest

final class Models_Paywall: XCTestCase {
    var backend: Backend!
    var session: HTTPSession!
    var decoder: JSONDecoder!

    override func setUpWithError() throws {
        try super.setUpWithError()

        (backend, session) = Tester.createBackendAndSession(id: "test")
        decoder = session.configuration.decoder
    }

    func test_Create() throws {
        let data = try Tester.jsonDataNamed("paywall_example")
        let result = try decoder.decode(Paywall.self, from: data)

        XCTAssertEqual(result.products.count, 2)
    }

    func test_No_Timestamp() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("paywall_no_timestamp")

        let exp = expectation(description: "Error expectation")
        do {
            let _ = try decoder.decode(Paywall.self, from: data)
        } catch {
            exp.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_Empty_Products() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("paywall_empty_products")
        let result = try decoder.decode(Paywall.self, from: data)

        XCTAssertEqual(result.products.count, 0)
    }

    func test_No_Products() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("paywall_no_products")

        let exp = expectation(description: "Error expectation")
        do {
            let _ = try decoder.decode(Paywall.self, from: data)
        } catch {
            exp.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_Currupted_Payload() throws {
        let decoder = JSONDecoder()
        let data = try Tester.jsonDataNamed("paywall_corrupted_payload")

        let exp = expectation(description: "Error expectation")
        do {
            let _ = try decoder.decode(Paywall.self, from: data)
        } catch {
            exp.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
