//
//  ProductModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation
import StoreKit

public class ProductModel: NSObject, JSONCodable {
    
    @objc public enum PeriodUnit : UInt {
        case day
        case week
        case month
        case year
        case unknown
    }
    
    @objc public var vendorProductId: String
    
    @objc public var localizedDescription: String = ""
    @objc public var localizedTitle: String = ""
    @objc public var price: NSDecimalNumber = 0
    @objc public var currencyCode: String?
    @objc public var currencySymbol: String?
    @objc public var subscriptionPeriod: ProductSubscriptionPeriodModel?
    @objc public var introductoryDiscount: ProductDiscountModel?
    @objc public var subscriptionGroupIdentifier: String?
    @objc public var discounts: [ProductDiscountModel] = []
    @objc public var localizedPriceString: String?
    @objc public var localizedIntroductoryPriceString: String?
    
    @objc public var skProduct: SKProduct? {
        didSet {
            guard let skProduct = skProduct else {
                return
            }
            
            localizedDescription = skProduct.localizedDescription
            localizedTitle = skProduct.localizedTitle
            price = skProduct.price
            currencyCode = skProduct.priceLocale.currencyCode
            currencySymbol = skProduct.priceLocale.currencySymbol
            
            if #available(iOS 11.2, *) {
                if let subscriptionPeriod = skProduct.subscriptionPeriod {
                    self.subscriptionPeriod = ProductSubscriptionPeriodModel(subscriptionPeriod: subscriptionPeriod)
                }
                if let introductoryDiscount = skProduct.introductoryPrice {
                    self.introductoryDiscount = ProductDiscountModel(discount: introductoryDiscount, locale: skProduct.priceLocale)
                }
            }
            if #available(iOS 12.0, *) {
                subscriptionGroupIdentifier = skProduct.subscriptionGroupIdentifier
            }
            if #available(iOS 12.2, *) {
                skProduct.discounts.forEach { (discount) in
                    discounts.append(ProductDiscountModel(discount: discount, locale: skProduct.priceLocale))
                }
            }

            localizedPriceString = price.localizedPrice(for: skProduct.priceLocale)
            localizedIntroductoryPriceString = introductoryDiscount?.price.localizedPrice(for: skProduct.priceLocale)
        }
    }
    
    required init?(json: Parameters) throws {
        guard
            let vendorProductId = json["vendor_product_id"] as? String
        else {
            throw SerializationError.missing("vendorProductId")
        }
        
        self.vendorProductId = vendorProductId
    }
    
}

public class ProductSubscriptionPeriodModel: NSObject {
    
    @objc public var unit: ProductModel.PeriodUnit
    @objc public var numberOfUnits: Int
    
    @available(iOS 11.2, *)
    init(subscriptionPeriod: SKProductSubscriptionPeriod) {
        self.unit = ProductModel.PeriodUnit(rawValue: subscriptionPeriod.unit.rawValue) ?? .unknown
        self.numberOfUnits = subscriptionPeriod.numberOfUnits
    }
    
}

public class ProductDiscountModel: NSObject {
    
    @objc public enum PaymentMode: UInt {
        case payAsYouGo
        case payUpFront
        case freeTrial
        case unknown
    }
    
    @objc public var price: NSDecimalNumber
    @objc public var identifier: String?
    @objc public var subscriptionPeriod: ProductSubscriptionPeriodModel
    @objc public var numberOfPeriods: Int
    @objc public var paymentMode: PaymentMode
    @objc public var localizedPriceString: String?
    
    @available(iOS 11.2, *)
    init(discount: SKProductDiscount, locale: Locale) {
        self.price = discount.price
        if #available(iOS 12.2, *) {
            self.identifier = discount.identifier
        }
        self.subscriptionPeriod = ProductSubscriptionPeriodModel(subscriptionPeriod: discount.subscriptionPeriod)
        self.numberOfPeriods = discount.numberOfPeriods
        self.paymentMode = PaymentMode(rawValue: discount.paymentMode.rawValue) ?? .unknown
        self.localizedPriceString = price.localizedPrice(for: locale)
    }
    
}
