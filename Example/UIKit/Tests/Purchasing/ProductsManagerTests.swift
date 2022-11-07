//
//  ProductsManagerTests.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 30.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import StoreKitTest
import XCTest

class ProductVendorIdsStorageForTest: ProductVendorIdsStorage {
    let profileId: String
    var vendorIds: VH<[String]>?
    func setProductVendorIds(_ value: VH<[String]>) { vendorIds = value }
    func getProductVendorIds() -> VH<[String]>? { vendorIds }

    init(profileId: String) {
        self.profileId = profileId
    }
}

final class ProductsManagerTests: XCTestCase {
    let profileId = TestsConstants.existingProfileId
    var backend: Backend!
    var session: HTTPSession!
    var manager: SKProductsManager!
    var storeSession: SKTestSession!

    override func setUpWithError() throws {
        let storage = ProductVendorIdsStorageForTest(profileId: profileId)
        (backend, session) = Tester.createBackendAndSession(id: "products")
        manager = SKProductsManager(storage: storage, backend: backend)

        storeSession = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        storeSession.resetToDefaultState()
        storeSession.disableDialogs = true
        storeSession.clearTransactions()
    }

    func test_Fetch_Products() throws {
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let ids: Set<String> = ["yearly.premium.6999", "consumable_apples_99", "unlimited.9999", "monthly.premium.999", "weekly.premium.599"]

        manager.fetchProducts(productIdentifiers: ids) { result in
            switch result {
            case let .success(products):
                XCTAssertEqual(ids.count, products.count)
            case .failure:
                XCTFail()
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }

    func test_Fetch_UnknownProducts() throws {
        let expectation = expectation(description: "Wait for result \(TestsConstants.timeoutInterval) sec.")
        let ids: Set<String> = ["strange.111", "very.strange.222"]

        manager.fetchProducts(productIdentifiers: ids) { result in
            switch result {
            case let .success(products):
                XCTAssertEqual(products.count, 0)
            case .failure:
                XCTFail()
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: TestsConstants.timeoutInterval)
    }
}
