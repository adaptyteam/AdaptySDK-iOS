//
//  ModelsTests.swift
//  Adapty_Tests
//
//  Created by Andrey Kyashkin on 07.12.2020.
//  Copyright © 2020 Adapty. All rights reserved.
//

import XCTest
import Nimble
import StoreKit
@testable import Adapty

class ModelsTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    private func attributes(from params: Parameters) -> Parameters {
        return ["attributes": params]
    }
    
    private var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    // MARK: - Network
    
    func testJSONModel() {
        let json = ["key": "value"]
        
        expect(try JSONModel(json: json)).toNot(throwError())
        
        let model = (try! JSONModel(json: json))!
        expect(model.data.description) == json.description
    }
    
    func testJSONAttributedModel() {
        expect { try JSONAttributedModel(json: Parameters()) } .to(throwError())
        
        let params = ["key": "value"]
        let json = attributes(from: params)
        
        expect(try JSONAttributedModel(json: json)).toNot(throwError())
        
        let model = (try! JSONAttributedModel(json: json))!
        expect(model.data.description) == params.description
    }
    
    func testResponseErrorModel() {
        let status = "404"
        let detail = "Bad request"
        let json = ["status": status, "detail": detail]
        
        expect(try ResponseErrorModel(json: json)).toNot(throwError())
        
        let model = (try! ResponseErrorModel(json: json))!
        expect(model.status) == Int(status)
        expect(model.detail) == detail
        expect(model.description.count) != 0
        
        let emptyModel = (try! ResponseErrorModel(json: Parameters()))!
        expect(emptyModel.status) == 0
        expect(emptyModel.detail) == ""
    }
    
    func testResponseErrorsArray() {
        let nilModel = try? ResponseErrorsArray(json: Parameters())
        expect(nilModel).to(beNil())
        
        let status = "404"
        let json = ["errors": [["status": status]]]
        
        expect(try ResponseErrorsArray(json: json)).toNot(throwError())
        
        let model = (try! ResponseErrorsArray(json: json))!
        expect(model.errors.count) == 1
        expect(model.errors.first?.status) == Int(status)
    }
    
    func testJSONParameterEncoder() {
        let request = URLRequest(url: URL(string: "https://adapty.io/")!)
        // the only way to cause throwable error from JSONSerialization.data(withJSONObject: options:)
        let bogusString = String(bytes: [0xD8, 0x00] as [UInt8], encoding: .utf16BigEndian)!
        let params = ["key": bogusString]
        expect(try JSONParameterEncoder().encode(request, with: params)).to(throwError())
    }
    
    func testURLParameterEncoder() {
        let request = NSURLRequest()
        expect(try URLParameterEncoder().encode(request as URLRequest, with: Parameters())).to(throwError())
    }
    
    // MARK: - User
    
    func testInstallationModel() {
        expect { try InstallationModel(json: Parameters()) } .to(throwError())
        expect { try InstallationModel(json: self.attributes(from: Parameters())) } .to(throwError())
        
        let id = "id_value"
        let json = attributes(from: ["id": id])
        
        expect(try InstallationModel(json: json)).toNot(throwError())
        
        let model = (try! InstallationModel(json: json))!
        expect(model.profileInstallationMetaId) == id
        
        let differentModel = try? InstallationModel(json: attributes(from: ["id": "id_value_2"]))
        expect(model) != differentModel
    }
    
    func testPurchaserInfoModel() throws {
        guard let url = bundle.url(forResource: "PurchaserInfo", withExtension: "json") else {
            XCTFail("Missing file: PurchaserInfo.json")
            return
        }
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let purchaserInfo = try PurchaserInfoModel(json: attributes(from: json))
        
        expect(purchaserInfo?.profileId).to(equal("e44cc1ff-30c2-4e99-9349-48c78cd8ec62"))
        expect(purchaserInfo?.subscriptions["basic_subscription_1_month"]?.vendorTransactionId)
            .to(equal("100000084301705511"))
        expect(purchaserInfo?.accessLevels["standard"]?.vendorProductId).to(equal("basic_subscription_1_month"))
        expect(purchaserInfo?.nonSubscriptions["coins_pack_100"]?.first?.vendorProductId).to(equal("coins_pack_100"))
    }
    
    // MARK: - Purchases
    
    func testPaywallModel() throws {
        guard let url = bundle.url(forResource: "Paywall", withExtension: "json") else {
            XCTFail("Missing file: Paywall.json")
            return
        }
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let paywall = try PaywallModel(json: attributes(from: json))
        
        expect(paywall?.developerId).to(equal("main_paywall"))
        expect(paywall?.variationId).to(equal("23b3f5e7-5490-49e7-ad45-33e8ae3a3e97"))
        expect(paywall?.revision).to(equal(3))
        expect(paywall?.products.count).to(equal(2))
        expect(paywall?.products.first?.vendorProductId).to(equal("basic_subscription_1_month"))
    }
    
    func testProductModel() throws {
        guard let url = bundle.url(forResource: "Product", withExtension: "json") else {
            XCTFail("Missing file: Product.json")
            return
        }
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let product = try ProductModel(json: json)
        
        let skProduct = SKProduct(identifier: product!.vendorProductId)
        product?.skProduct = skProduct
        
        expect(product?.vendorProductId).to(equal("basic_subscription_1_year"))
        expect(product?.introductoryOfferEligibility).to(beFalse())
        expect(product?.promotionalOfferEligibility).to(beTrue())
        expect(product?.promotionalOfferId).to(beNil())
        expect(product?.introductoryDiscount?.paymentMode.rawValue).to(equal(PaymentMode.payAsYouGo.rawValue))
        expect(product?.subscriptionPeriod?.unit).to(equal(ProductModel.PeriodUnit.year))
    }
    
    func testPaywallsArray() throws {
        guard let url = bundle.url(forResource: "PaywallArray", withExtension: "json") else {
            XCTFail("Missing file: PaywallArray.json")
            return
        }
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        let paywallsArray = try PaywallsArray(json: json)
        expect(paywallsArray?.paywalls.count).to(equal(1))
        expect(paywallsArray?.products.count).to(equal(2))
    }
    
    func testPromoModel() {
        expect { try PromoModel(json: Parameters()) } .to(throwError())
        expect { try PromoModel(json: self.attributes(from: Parameters())) } .to(throwError())
        
        let promoType = "promo_type_value"
        let variationId = "variation_id_value"
        let expiresAt = "2020-01-17T15:33:03.205463+0000"
        var params: Parameters = ["promo_type": promoType, "variation_id": variationId, "expires_at": expiresAt]
        let json = attributes(from: params)
        
        expect(try PromoModel(json: json)).toNot(throwError())
        
        let model = (try! PromoModel(json: json))!
        expect(model.promoType) == promoType
        expect(model.variationId) == variationId
        expect(model.expiresAt) == expiresAt.dateValue
        
        params = params.mutateOnly("expires_at", to: nil)
        let modelWithDifferentExpiresAt = try? PromoModel(json: attributes(from: params))
        expect(model) != modelWithDifferentExpiresAt
        
        params = params.mutateOnly("variation_id", to: "")
        let modelWithDifferentVariationId = try? PromoModel(json: attributes(from: params))
        expect(model) != modelWithDifferentVariationId
        
        params = params.mutateOnly("promo_type", to: "")
        let modelWithDifferentPromoType = try? PromoModel(json: attributes(from: params))
        expect(model) != modelWithDifferentPromoType
        
        params = params.rollbackMutation()
        let paywallParams: Parameters = ["developer_id": "", "variation_id": "", "products": [Parameters]()]
        model.paywall = try? PaywallModel(json: attributes(from: paywallParams))
        
        let modelWithDifferentPaywall = try? PromoModel(json: json)
        expect(model) != modelWithDifferentPaywall
    }

}

private extension Dictionary where Key == String, Value == Any {
    
    func mutateOnly(_ key: String, to value: Any?) -> Parameters {
        var mutableSelf = rollbackMutation()
        
        mutableSelf["MUTATED_KEY"] = key
        mutableSelf["MUTATED_VALUE"] = mutableSelf[key]
        mutableSelf[key] = value
        
        return mutableSelf
    }
    
    func rollbackMutation() -> Parameters {
        var mutableSelf = self
        
        if let previousKey = self["MUTATED_KEY"] as? String, let previousValue = self["MUTATED_VALUE"] {
            mutableSelf[previousKey] = previousValue
        }
        
        return mutableSelf
    }
    
}

public extension SKProduct {
    convenience init(identifier: String) {
        self.init()
        setValue(identifier, forKey: "productIdentifier")
        setValue(NSDecimalNumber(string: "20"), forKey: "price")
        setValue(Locale.current, forKey: "priceLocale")
        
        let subscriptionPeriod = SKProductSubscriptionPeriod()
        subscriptionPeriod.setValue(1, forKey: "numberOfUnits")
        subscriptionPeriod.setValue(SKProduct.PeriodUnit.year.rawValue, forKey: "unit")
        setValue(subscriptionPeriod, forKey: "subscriptionPeriod")
        
        let discount = SKProductDiscount()
        discount.setValue(NSDecimalNumber(string: "10"), forKey: "price")
        discount.setValue(identifier, forKey: "identifier")
        discount.setValue(subscriptionPeriod, forKey: "subscriptionPeriod")
        discount.setValue(1, forKey: "numberOfPeriods")
        discount.setValue(SKProductDiscount.PaymentMode.payAsYouGo.rawValue, forKey: "paymentMode")
        setValue(discount, forKey: "introductoryPrice")
    }
}
