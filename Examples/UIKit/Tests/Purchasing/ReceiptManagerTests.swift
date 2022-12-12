//
//  ReceiptManagerTests.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 30.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import StoreKitTest
import XCTest

final class ReceiptManagerTests: XCTestCase {
    var backend: Backend!
    var session: HTTPSession!
    var storage: UserDefaults!

    var manager: SKReceiptManager!
    var storeSession: SKTestSession!

    override func setUpWithError() throws {
        (backend, session) = Tester.createBackendAndSession(id: "ReceiptManagerTests")
        storage = UserDefaults(suiteName: "ReceiptManagerTests")
        manager = SKReceiptManager(queue: DispatchQueue(label: "Adapty.SDK.ReceiptManagerTests"),
                                   storage: storage,
                                   backend: backend)

        storeSession = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        storeSession.resetToDefaultState()
        storeSession.disableDialogs = true
        storeSession.clearTransactions()
    }

    override func tearDownWithError() throws {
        storage.removeSuite(named: "ReceiptManagerTests")

        try super.tearDownWithError()
    }

    func test_GetReceipt() throws {
        let expectation = XCTestExpectation()

        manager.getReceipt(refreshIfEmpty: false) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }

            expectation.fulfill()
        }
    }

    func test_GetReceipt_RefreshIfEmpty() throws {
        let expectation = XCTestExpectation()

        manager.getReceipt(refreshIfEmpty: true) { result in
            switch result {
            case let .success(receipt):
                XCTAssertNotNil(receipt)
            case .failure:
                XCTFail()
            }

            expectation.fulfill()
        }
    }
}
