//
//  ProductModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation
import StoreKit

public class ProductModel: NSObject, JSONCodable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case vendorProductId
        case introductoryOfferEligibility
        case promotionalOfferEligibility
        case promotionalOfferId
        case variationId
        case paywallABTestName
        case paywallName
        case localizedDescription
        case localizedTitle
        case price
        case currencyCode
        case currencySymbol
        case regionCode
        case isFamilyShareable
        case subscriptionPeriod
        case introductoryDiscount
        case subscriptionGroupIdentifier
        case discounts
        case localizedPrice
        case localizedSubscriptionPeriod
    }
    
    @objc public enum PeriodUnit : UInt, Codable {
        case day
        case week
        case month
        case year
        case unknown
    }
    
    @objc public var vendorProductId: String
    @objc public var introductoryOfferEligibility: Bool = false
    @objc public var promotionalOfferEligibility: Bool = false
    @objc public var promotionalOfferId: String?
    var variationId: String?
    @objc public var paywallABTestName: String?
    @objc public var paywallName: String?
    
    // filled from SKProduct
    @objc public var localizedDescription: String = ""
    @objc public var localizedTitle: String = ""
    @objc public var price: Decimal = 0
    @objc public var currencyCode: String?
    @objc public var currencySymbol: String?
    @objc public var regionCode: String?
    @objc public var isFamilyShareable: Bool = false
    @objc public var subscriptionPeriod: ProductSubscriptionPeriodModel?
    @objc public var introductoryDiscount: ProductDiscountModel?
    @objc public var subscriptionGroupIdentifier: String?
    @objc public var discounts: [ProductDiscountModel] = []
    @objc public var localizedPrice: String?
    @objc public var localizedSubscriptionPeriod: String?
    
    @objc public var skProduct: SKProduct? {
        didSet {
            guard let skProduct = skProduct else {
                return
            }
            
            localizedDescription = skProduct.localizedDescription
            localizedTitle = skProduct.localizedTitle
            price = skProduct.price.decimalValue
            currencyCode = skProduct.priceLocale.currencyCode
            currencySymbol = skProduct.priceLocale.currencySymbol
            regionCode = skProduct.priceLocale.regionCode
            
            #if swift(>=5.3)
            if #available(iOS 14.0, macOS 11.0, *) {
                isFamilyShareable = skProduct.isFamilyShareable
            }
            #endif
            if #available(iOS 11.2, macOS 10.14.4, *) {
                if let subscriptionPeriod = skProduct.subscriptionPeriod {
                    self.subscriptionPeriod = ProductSubscriptionPeriodModel(subscriptionPeriod: subscriptionPeriod)
                    self.localizedSubscriptionPeriod = subscriptionPeriod.localizedPeriod(for: skProduct.priceLocale)
                }
                if let introductoryDiscount = skProduct.introductoryPrice {
                    self.introductoryDiscount = ProductDiscountModel(discount: introductoryDiscount, locale: skProduct.priceLocale)
                }
            }
            if #available(iOS 12.0, macOS 10.14, *) {
                subscriptionGroupIdentifier = skProduct.subscriptionGroupIdentifier
            }
            if #available(iOS 12.2, macOS 10.14.4, *) {
                skProduct.discounts.forEach { (discount) in
                    discounts.append(ProductDiscountModel(discount: discount, locale: skProduct.priceLocale))
                }
            }

            localizedPrice = skProduct.price.localizedPrice(for: skProduct.priceLocale)
        }
    }
    
    required init?(json: Parameters) throws {
        guard
            let vendorProductId = json["vendor_product_id"] as? String
        else {
            throw AdaptyError.missingParam("ProductModel - vendorProductId")
        }
        
        self.vendorProductId = vendorProductId
        if let introductoryOfferEligibility = json["introductory_offer_eligibility"] as? Bool { self.introductoryOfferEligibility = introductoryOfferEligibility }
        if let promotionalOfferEligibility = json["promotional_offer_eligibility"] as? Bool { self.promotionalOfferEligibility = promotionalOfferEligibility }
        self.promotionalOfferId = json["promotional_offer_id"] as? String
    }
    
    func fillMissingProperties(from product: ProductModel) {
        self.introductoryOfferEligibility = product.introductoryOfferEligibility
        self.promotionalOfferEligibility = product.promotionalOfferEligibility
        self.promotionalOfferId = product.promotionalOfferId
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ProductModel else {
            return false
        }
        
        return self.vendorProductId == object.vendorProductId && self.introductoryOfferEligibility == object.introductoryOfferEligibility && self.promotionalOfferEligibility == object.promotionalOfferEligibility && self.promotionalOfferId == object.promotionalOfferId && self.variationId == object.variationId && self.localizedDescription == object.localizedDescription && self.localizedTitle == object.localizedTitle && self.price == object.price && self.currencyCode == object.currencyCode && self.currencySymbol == object.currencySymbol && self.regionCode == object.regionCode && self.isFamilyShareable == object.isFamilyShareable && self.subscriptionPeriod == object.subscriptionPeriod && self.introductoryDiscount == object.introductoryDiscount && self.subscriptionGroupIdentifier == object.subscriptionGroupIdentifier && self.discounts == object.discounts && self.localizedPrice == object.localizedPrice && self.localizedSubscriptionPeriod == object.localizedSubscriptionPeriod && self.paywallABTestName == object.paywallABTestName && self.paywallName == object.paywallName
    }
    
}

public class ProductSubscriptionPeriodModel: NSObject, Codable {
    
    @objc public var unit: ProductModel.PeriodUnit
    @objc public var numberOfUnits: Int
    
    @available(iOS 11.2, macOS 10.13.2, *)
    init(subscriptionPeriod: SKProductSubscriptionPeriod) {
        self.unit = ProductModel.PeriodUnit(rawValue: subscriptionPeriod.unit.rawValue) ?? .unknown
        self.numberOfUnits = subscriptionPeriod.numberOfUnits
    }
    
    func unitString() -> String? {
        switch unit {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        case .unknown:
            return nil
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ProductSubscriptionPeriodModel else {
            return false
        }
        
        return self.unit == object.unit && self.numberOfUnits == object.numberOfUnits
    }
    
}

public class ProductDiscountModel: NSObject, Codable {
    
    @objc public enum PaymentMode: UInt, Codable {
        case payAsYouGo
        case payUpFront
        case freeTrial
        case unknown
    }
    
    @objc public var price: Decimal
    @objc public var identifier: String?
    @objc public var subscriptionPeriod: ProductSubscriptionPeriodModel
    @objc public var numberOfPeriods: Int
    @objc public var paymentMode: PaymentMode
    @objc public var localizedPrice: String?
    @objc public var localizedSubscriptionPeriod: String?
    @objc public var localizedNumberOfPeriods: String?
    
    @available(iOS 11.2, macOS 10.14.4, *)
    init(discount: SKProductDiscount, locale: Locale) {
        self.price = discount.price.decimalValue
        if #available(iOS 12.2, *) {
            self.identifier = discount.identifier
        }
        self.subscriptionPeriod = ProductSubscriptionPeriodModel(subscriptionPeriod: discount.subscriptionPeriod)
        self.numberOfPeriods = discount.numberOfPeriods
        self.paymentMode = PaymentMode(rawValue: discount.paymentMode.rawValue) ?? .unknown
        self.localizedPrice = discount.price.localizedPrice(for: locale)
        self.localizedSubscriptionPeriod = discount.subscriptionPeriod.localizedPeriod(for: locale)
        self.localizedNumberOfPeriods = discount.localizedNumberOfPeriods(for: locale)
    }
    
    func paymentModeString() -> String? {
        switch paymentMode {
        case .payAsYouGo:
            return "pay_as_you_go"
        case .payUpFront:
            return "pay_up_front"
        case .freeTrial:
            return "free_trial"
        case .unknown:
            return nil
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ProductDiscountModel else {
            return false
        }
        
        return self.price == object.price && self.identifier == object.identifier && self.subscriptionPeriod == object.subscriptionPeriod && self.numberOfPeriods == object.numberOfPeriods && self.paymentMode == object.paymentMode && self.localizedPrice == object.localizedPrice && self.localizedSubscriptionPeriod == object.localizedSubscriptionPeriod && self.localizedNumberOfPeriods == object.localizedNumberOfPeriods
    }
    
}
