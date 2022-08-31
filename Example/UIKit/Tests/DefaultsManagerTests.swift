//
//  DefaultsManagerTests.swift
//  Adapty_Tests
//
//  Created by Andrey Kyashkin on 27.11.2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

@testable import Adapty
import Nimble
import XCTest

class DefaultsManagerTests: XCTestCase {
    private var userDefaultsMock: UserDefaultsMock!
    private var defaultsManager: DefaultsManager!

    override func setUpWithError() throws {
        try super.setUpWithError()

        userDefaultsMock = UserDefaultsMock()
        defaultsManager = DefaultsManager(with: userDefaultsMock)
    }

    override func tearDownWithError() throws {
        userDefaultsMock = nil
        defaultsManager = nil

        try super.tearDownWithError()
    }

    func testProfileIdKey() {
        let profileId = "adapty"
        defaultsManager.profileId = profileId
        expect(self.defaultsManager.profileId).to(equal(profileId))
    }

    func testProfileIdDefaultGeneration() {
        let profileId = defaultsManager.profileId
        expect(profileId).toNot(beNil())
        expect(profileId).notTo(beEmpty())
    }

    func testPurchaserInfoCachingAndProfileIdGetterFromSavedPurchaserInfo() {
        expect(self.defaultsManager.purchaserInfo).to(beNil())

        let purchaserInfo = try? PurchaserInfoModel(json: ["attributes": ["id": "adapty"]])
        expect(purchaserInfo).toNot(beNil())

        defaultsManager.purchaserInfo = purchaserInfo

        expect(self.defaultsManager.purchaserInfo).to(equal(purchaserInfo))
        expect(self.defaultsManager.profileId).to(equal(purchaserInfo?.profileId))
    }

    func testInstallationCaching() {
        expect(self.defaultsManager.installation).to(beNil())

        let installation = try? InstallationModel(json: ["attributes": ["id": "adapty"]])
        expect(installation).toNot(beNil())

        defaultsManager.installation = installation

        expect(self.defaultsManager.installation).to(equal(installation))
    }

    func testCachedVariationsIdsCaching() {
        expect(self.defaultsManager.cachedVariationsIds).to(beEmpty())

        let variantsIds: [String: String] = ["product.vendorProductId": "product.variationId"]

        defaultsManager.cachedVariationsIds = variantsIds

        expect(self.defaultsManager.cachedVariationsIds).to(equal(variantsIds))
    }

    func testCachedEventsCaching() {
        expect(self.defaultsManager.cachedEvents).toNot(beNil())

        let cachedEvents = [[String: String]]()

        defaultsManager.cachedEvents = cachedEvents

        expect(self.defaultsManager.cachedEvents).to(equal(cachedEvents))
    }

    func testCachedPaywallsCaching() throws {
        expect(self.defaultsManager.cachedPaywalls).to(beNil())

        let paywall = try PaywallModel(json: ["attributes": ["developer_id": "developer_id",
                                                             "variation_id": "variation_id",
                                                             "products": []],
            ])
        let paywalls: [String: PaywallModel] = [paywall!.id: paywall!]

        defaultsManager.cachedPaywalls = paywalls

        expect(self.defaultsManager.cachedPaywalls).to(equal(paywalls))
    }

    func testCachedProductsCaching() throws {
        expect(self.defaultsManager.cachedProducts).to(beNil())

        let product = try ProductModel(json: ["vendor_product_id": "vendor_product_id"])
        let products: [ProductModel] = [product!]

        defaultsManager.cachedProducts = products

        expect(self.defaultsManager.cachedProducts).to(equal(products))
    }

    func testAppleSearchAdsSyncDateCaching() {
        expect(self.defaultsManager.appleSearchAdsSyncDate).to(beNil())

        let appleSearchAdsSyncDate = Date()

        defaultsManager.appleSearchAdsSyncDate = appleSearchAdsSyncDate

        expect(self.defaultsManager.appleSearchAdsSyncDate).to(equal(appleSearchAdsSyncDate))
    }

    func testExternalAnalyticsDisabledCaching() {
        expect(self.defaultsManager.externalAnalyticsDisabled).to(beFalse())

        defaultsManager.externalAnalyticsDisabled = true

        expect(self.defaultsManager.externalAnalyticsDisabled).to(beTrue())
    }

    func testPreviousResponseHashesCaching() {
        expect(self.defaultsManager.previousResponseHashes).to(beEmpty())

        let responseHash = ["routerType": "responseHash"]
        defaultsManager.previousResponseHashes = responseHash

        expect(self.defaultsManager.previousResponseHashes).to(equal(responseHash))
    }

    func testResponseJSONCachesCaching() {
        expect(self.defaultsManager.responseJSONCaches).to(beEmpty())

        let responseJSONHash = ["requestType": ["responseJSONHash": Data()]]
        defaultsManager.responseJSONCaches = responseJSONHash

        expect(self.defaultsManager.responseJSONCaches).to(equal(responseJSONHash))
    }

    func testPostRequestParamsHashesCaching() {
        expect(self.defaultsManager.postRequestParamsHashes).to(beEmpty())

        let postRequestParamHash = ["routerType": "requestParamsHash"]
        defaultsManager.postRequestParamsHashes = postRequestParamHash

        expect(self.defaultsManager.postRequestParamsHashes).to(equal(postRequestParamHash))
    }

    func testClean() {
        defaultsManager.clean()

        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.cachedEvents))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.cachedPaywalls))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.cachedProducts))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.appleSearchAdsSyncDate))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.cachedVariationsIds))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.externalAnalyticsDisabled))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.responseJSONCaches))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.previousResponseHashes))
        expect(self.userDefaultsMock.removedObjectsKeys).to(contain(DefaultsManager.Constants.postRequestParamsHashes))
    }
}
