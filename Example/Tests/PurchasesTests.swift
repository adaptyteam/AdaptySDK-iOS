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

    
    func testMakeSubscriptionPurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        
        let productData = try DataProvider().jsonDataNamed("Product_subscription")
        let json = try JSONSerialization.jsonObject(with: productData, options: []) as! [String: Any]
        let product = try ProductModel(json: json)!
        
        MockURLProtocol.removeAllStubs()
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
                expect(purchaserInfo?.subscriptions.first?.value.vendorProductId)
                    .to(equal(product?.vendorProductId))
                done()
            })
        }

        expect(session.allTransactions().count).to(equal(1))

        let transaction = session.allTransactions().first
        expect(transaction?.productIdentifier).to(equal(product.vendorProductId))
        expect(transaction?.autoRenewingEnabled).to(beTrue())
        expect(transaction?.state).to(equal(.purchased))
    }
    
    func testMakeConsumablePurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        
        let productData = try DataProvider().jsonDataNamed("Product_coins_200")
        let json = try JSONSerialization.jsonObject(with: productData, options: []) as! [String: Any]
        let product = try ProductModel(json: json)!
        
        MockURLProtocol.removeAllStubs()
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
                expect(purchaserInfo?.nonSubscriptions.first?.value.first?.vendorProductId)
                    .to(equal(product?.vendorProductId))
                done()
            })
        }

        expect(session.allTransactions().count).to(equal(1))

        let transaction = session.allTransactions().first
        expect(transaction?.productIdentifier).to(equal(product.vendorProductId))
        expect(transaction?.autoRenewingEnabled).to(beFalse())
        expect(transaction?.state).to(equal(.purchased))
    }
    
    func testMakeFailedTransactionConsumablePurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.interruptedPurchasesEnabled = true
        session.clearTransactions()

        let productData = try DataProvider().jsonDataNamed("Product_coins_200")
        let json = try JSONSerialization.jsonObject(with: productData, options: []) as! [String: Any]
        let product = try ProductModel(json: json)!

        MockURLProtocol.removeAllStubs()
        let paywallsStub = Stub(statusCode: 200, jsonFileName: "PaywallArray",
                                error: nil, urlMatcher: "purchase-containers")
        MockURLProtocol.addStab(paywallsStub)
        let validationStub = Stub(statusCode: 400, jsonFileName: nil,
                                  error: AdaptyError.badRequest, urlMatcher: "validate")
        MockURLProtocol.addStab(validationStub)

        let requestManager = RequestManager(session: .mock)
        let apiManager = ApiManager(requestManager:requestManager)
        let iapManager = IAPManager(apiManager: apiManager)
        iapManager.startObservingPurchases(nil)

        waitUntil(timeout: .seconds(10)) { done in
            iapManager.makePurchase(product: product, offerId: nil, completion: {
                purchaserInfo, receipt, appleValidationResult, product, error in
                expect(receipt).to(beNil())
                expect(purchaserInfo).to(beNil())
                expect(error?.adaptyErrorCode).to(equal(AdaptyError.AdaptyErrorCode.unknown))
                done()
            })
        }

        expect(session.allTransactions().count).to(equal(1))
        expect(session.allTransactions().first?.state).to(equal(.failed))
    }

    func testMakeFailedValidationConsumablePurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        
        let productData = try DataProvider().jsonDataNamed("Product_coins_100")
        let json = try JSONSerialization.jsonObject(with: productData, options: []) as! [String: Any]
        let product = try ProductModel(json: json)!
        
        MockURLProtocol.removeAllStubs()
        let paywallsStub = Stub(statusCode: 200, jsonFileName: "PaywallArray",
                                error: nil, urlMatcher: "purchase-containers")
        MockURLProtocol.addStab(paywallsStub)
        let validationStub = Stub(statusCode: 400, jsonFileName: nil,
                                  error: AdaptyError.badRequest, urlMatcher: "validate")
        MockURLProtocol.addStab(validationStub)
        
        let requestManager = RequestManager(session: .mock)
        let apiManager = ApiManager(requestManager:requestManager)
        let iapManager = IAPManager(apiManager: apiManager)
        iapManager.startObservingPurchases(nil)

        waitUntil(timeout: .seconds(10)) { done in
            iapManager.makePurchase(product: product, offerId: nil, completion: {
                purchaserInfo, receipt, appleValidationResult, product, error in
                expect(error).to(beNil())
                expect(purchaserInfo).to(beNil())
                done()
            })
        }

        expect(session.allTransactions().count).to(equal(1))

        let transaction = session.allTransactions().first
        expect(transaction?.productIdentifier).to(equal(product.vendorProductId))
        expect(transaction?.autoRenewingEnabled).to(beFalse())
        expect(transaction?.state).to(equal(.purchased))
    }
    
    func testRestorePurchase() throws {
        let session = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        
        let requestManager = RequestManager(session: .mock)
        let apiManager = ApiManager(requestManager:requestManager)
        let iapManager = IAPManager(apiManager: apiManager)
        iapManager.startObservingPurchases(nil)
        
        MockURLProtocol.removeAllStubs()
        let paywallsStub = Stub(statusCode: 200, jsonFileName: "PaywallArray",
                                error: nil, urlMatcher: "purchase-containers")
        MockURLProtocol.addStab(paywallsStub)
        
        waitUntil(timeout: .seconds(10)) { done in
            iapManager.restorePurchases { purchaserInfo, receipt, appleValidationResult, error in
                expect(error).to(equal(AdaptyError.noPurchasesToRestore))
                done()
            }
        }
    }
    
    func testTransactionsHistory() throws {
        let session = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        
        let productIdentifier = "coins_pack_100"
        expect(try session.buyProduct(productIdentifier: productIdentifier)).notTo(throwError())
        
        MockURLProtocol.removeAllStubs()
        let validationStub = Stub(statusCode: 200, jsonFileName: "ValidationResponse",
                                  error: nil, urlMatcher: "validate")
        MockURLProtocol.addStab(validationStub)
        let paywallsStub = Stub(statusCode: 200, jsonFileName: "PaywallArray",
                                error: nil, urlMatcher: "purchase-containers")
        MockURLProtocol.addStab(paywallsStub)
        
        let requestManager = RequestManager(session: .mock)
        let apiManager = ApiManager(requestManager:requestManager)
        let iapManager = IAPManager(apiManager: apiManager)
        iapManager.startObservingPurchases(nil)
        iapManager.syncTransactionsHistory()
        
        expect(iapManager.paywalls?.count).to(equal(1))
        expect(iapManager.products?.count).to(equal(3))
        
        expect(DefaultsManager.shared.purchaserInfo).notTo(beNil())
    }
}
