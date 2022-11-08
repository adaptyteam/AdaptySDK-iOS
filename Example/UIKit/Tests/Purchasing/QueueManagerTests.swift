//
//  QueueManagerTests.swift
//  Adapty_Tests
//
//  Created by Aleksey Goncharov on 31.10.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

@testable import Adapty
import StoreKitTest
import XCTest

class VariationIdStorageForTest : VariationIdStorage {
    var data = [String: String]()
    func getVariationsIds() -> [String: String] { data }
    func setVariationsIds(_ value : [String: String]) { data = value}
}

struct TestableProduct: AdaptyProduct {
    var vendorProductId: String
    var skProduct: SKProduct

    init(vendorProductId: String, skProduct: SKProduct) {
        self.vendorProductId = vendorProductId
        self.skProduct = skProduct
    }
}

extension TestableProduct: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProductCodingKeys.self)
        try container.encode(vendorProductId, forKey: .vendorProductId)
    }
}

class TestablePurchaseValiadator: ReceiptValidator {
    let decoder: JSONDecoder

    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    var purchasedProduct: PurchaseProductInfo?

    func validateReceipt(purchaseProductInfo: PurchaseProductInfo?, refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        purchasedProduct = purchaseProductInfo

        do {
            let profileData = try Tester.jsonDataNamed("profile_empty")
            let profile = try decoder.decode(AdaptyProfile.self, from: profileData)
            completion(.success(profile))
        } catch {
            completion(.failure(.cantMakePayments()))
        }
    }
}

final class QueueManagerTests: XCTestCase {
    let profileId = TestsConstants.existingProfileId
    var backend: Backend!
    var session: HTTPSession!

    var productsManager: SKProductsManager!

    override func setUpWithError() throws {
        let storage = ProductVendorIdsStorageForTest(profileId: profileId)
        (backend, session) = Tester.createBackendAndSession(id: "products")

        productsManager = SKProductsManager(storage: storage, backend: backend)
    }

    func test_Purchase_Success() throws {
        let storeSession = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        storeSession.resetToDefaultState()
        storeSession.disableDialogs = true
        storeSession.clearTransactions()

        let productExpectation = XCTestExpectation()
        let purchaseExpectation = XCTestExpectation()

        var product: SKProduct!

        productsManager.fetchProducts(productIdentifiers: ["consumable_apples_99"]) { result in
            product = try? result.get().first
            productExpectation.fulfill()
        }

        wait(for: [productExpectation], timeout: TestsConstants.timeoutInterval)

        let validator = TestablePurchaseValiadator(decoder: session.configuration.decoder)
        let queueManager = SKQueueManager(queue: .main, storage: VariationIdStorageForTest())
        queueManager.startObserving(receiptValidator: validator)

        let payment = SKPayment(product: product)
        let testableProduct = TestableProduct(vendorProductId: product.productIdentifier, skProduct: product)

        queueManager.makePurchase(payment: payment, product: testableProduct) { result in
            switch result {
            case .success:
                XCTAssertEqual(validator.purchasedProduct?.vendorProductId, testableProduct.vendorProductId)

                if let transaction = storeSession.allTransactions().first(where: { $0.productIdentifier == testableProduct.vendorProductId }) {
                    XCTAssertEqual(transaction.state, .purchased)
                } else {
                    XCTFail("It is supposed to be a transaction here")
                }
            case .failure:
                XCTFail()
            }

            purchaseExpectation.fulfill()
        }

        wait(for: [purchaseExpectation], timeout: TestsConstants.timeoutInterval)
    }
    
    func test_Purchase_Failed() throws {
        let storeSession = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        storeSession.resetToDefaultState()
        storeSession.clearTransactions()
        storeSession.disableDialogs = true
        storeSession.failTransactionsEnabled = true
        
        let productExpectation = XCTestExpectation()
        let purchaseExpectation = XCTestExpectation()

        var product: SKProduct!
        
        productsManager.fetchProducts(productIdentifiers: ["consumable_apples_99"]) { result in
            product = try? result.get().first
            productExpectation.fulfill()
        }

        wait(for: [productExpectation], timeout: TestsConstants.timeoutInterval)

        let validator = TestablePurchaseValiadator(decoder: session.configuration.decoder)
        let queueManager = SKQueueManager(queue: .main, storage: VariationIdStorageForTest())
        queueManager.startObserving(receiptValidator: validator)

        let payment = SKPayment(product: product)
        let testableProduct = TestableProduct(vendorProductId: product.productIdentifier, skProduct: product)

        queueManager.makePurchase(payment: payment, product: testableProduct) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                break
            }

            purchaseExpectation.fulfill()
        }

        wait(for: [purchaseExpectation], timeout: TestsConstants.timeoutInterval)
    }
    
    func test_Purchase_Interrupted() throws {
        let storeSession = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        storeSession.resetToDefaultState()
        storeSession.clearTransactions()
        storeSession.disableDialogs = true
        storeSession.interruptedPurchasesEnabled = true
        
        let productExpectation = XCTestExpectation()
        let purchaseExpectation = XCTestExpectation()

        var product: SKProduct!
        
        productsManager.fetchProducts(productIdentifiers: ["consumable_apples_99"]) { result in
            product = try? result.get().first
            productExpectation.fulfill()
        }

        wait(for: [productExpectation], timeout: TestsConstants.timeoutInterval)

        let validator = TestablePurchaseValiadator(decoder: session.configuration.decoder)
        let queueManager = SKQueueManager(queue: .main, storage: VariationIdStorageForTest())
        queueManager.startObserving(receiptValidator: validator)

        let payment = SKPayment(product: product)
        let testableProduct = TestableProduct(vendorProductId: product.productIdentifier, skProduct: product)
        
        queueManager.makePurchase(payment: payment, product: testableProduct) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                break
            }

            purchaseExpectation.fulfill()
        }

        wait(for: [purchaseExpectation], timeout: TestsConstants.timeoutInterval)
    }
    
    func test_Purchase_AskToBuy() throws {
        let storeSession = try SKTestSession(configurationFileNamed: "StoreKitConfiguration")
        storeSession.resetToDefaultState()
        storeSession.clearTransactions()
        storeSession.disableDialogs = true
        storeSession.askToBuyEnabled = true
        
        let productExpectation = XCTestExpectation()
        let purchaseExpectation = XCTestExpectation()

        var product: SKProduct!
        
        productsManager.fetchProducts(productIdentifiers: ["consumable_apples_99"]) { result in
            product = try? result.get().first
            productExpectation.fulfill()
        }

        wait(for: [productExpectation], timeout: TestsConstants.timeoutInterval)

        let validator = TestablePurchaseValiadator(decoder: session.configuration.decoder)
        let queueManager = SKQueueManager(queue: .main, storage: VariationIdStorageForTest())
        queueManager.startObserving(receiptValidator: validator)

        let payment = SKPayment(product: product)
        let testableProduct = TestableProduct(vendorProductId: product.productIdentifier, skProduct: product)

        queueManager.makePurchase(payment: payment, product: testableProduct) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail()
            }

            purchaseExpectation.fulfill()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            guard let transaction = storeSession.allTransactions().first else {
                XCTFail("It is supposed to be a transaction here")
                return
            }
            
            do {
                try storeSession.approveAskToBuyTransaction(identifier: transaction.identifier)
            } catch {
                XCTFail()
            }
        }
        

        wait(for: [purchaseExpectation], timeout: TestsConstants.timeoutInterval)
    }
}
