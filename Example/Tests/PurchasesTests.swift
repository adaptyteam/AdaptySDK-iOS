//
//  PurchasesTests.swift
//  Adapty_Tests
//
//  Created by Rustam on 05.12.2021.
//  Copyright © 2021 Adapty. All rights reserved.
//

import XCTest
import StoreKitTest
import Nimble
@testable import Adapty
import Adjust

@available(iOS 14.0, *)
class PurchasesTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    
    func testMakePurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        
        let productData = try DataProvider().jsonDataNamed("Product_subscription")
        let json = try JSONSerialization.jsonObject(with: productData, options: []) as! [String: Any]
        let product = try ProductModel(json: json)!
        
        let paywallsStub = Stub(statusCode: 200, jsonFileName: "PaywallArray",
                                error: nil, urlMatcher: "purchase-containers")
        MockURLProtocol.addStab(paywallsStub)
        
        let validationStub = Stub(statusCode: 200, jsonFileName: "ValidationResponse",
                                  error: nil, urlMatcher: "validate")
        MockURLProtocol.addStab(validationStub)
        
        let requestManager = RequestManager(session: .mock)
        let apiManager = ApiManager(requestManager:requestManager)
        let iapManager = IAPManager(apiManager: apiManager)
        iapManager.startObservingPurchases(nil)
        
        waitUntil(timeout: .seconds(10)) { done in
            iapManager.makePurchase(product: product, offerId: nil, completion: {
                purchaserInfo, receipt, appleValidationResult, product, error in
                expect(purchaserInfo).notTo(beNil())
                done()
            })
        }

        expect(session.allTransactions().count).to(equal(1))

        let transaction = session.allTransactions()[0]
        expect(transaction.productIdentifier).to(equal(product.vendorProductId))
        expect(transaction.autoRenewingEnabled).to(beTrue())
        expect(transaction.state).to(equal(.purchased))
    }
}
