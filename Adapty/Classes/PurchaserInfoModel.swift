//
//  PurchaserInfoModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 04/02/2020.
//

import Foundation

public class PurchaserInfoModel: NSObject, JSONCodable {

    public var promotionalOfferEligibility: Bool
    public var introductoryOfferEligibility: Bool
    public var paidAccessLevels: [String: PaidAccessLevelsInfoModel]
    public var subscriptions: [String: SubscriptionsInfoModel]
    public var nonSubscriptions: [String: [NonSubscriptionsInfoModel]]
    var appleValidationResult: Parameters?
    
    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let promotionalOfferEligibility = attributes?["promotional_offer_eligibility"] as? Bool,
            let introductoryOfferEligibility = attributes?["introductory_offer_eligibility"] as? Bool
        else {
            throw SerializationError.missing("promotional_offer_eligibility, introductory_offer_eligibility")
        }
        
        self.promotionalOfferEligibility = promotionalOfferEligibility
        self.introductoryOfferEligibility = introductoryOfferEligibility
        
        var paidAccessLevels = [String: PaidAccessLevelsInfoModel]()
        var subscriptions = [String: SubscriptionsInfoModel]()
        var nonSubscriptions = [String: [NonSubscriptionsInfoModel]]()
        do {
            if let data = attributes?["paid_access_levels"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? Parameters else {
                        continue
                    }
                    
                    paidAccessLevels[key] = try PaidAccessLevelsInfoModel(json: value)
                }
            }
            
            if let data = attributes?["subscriptions"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? Parameters else {
                        continue
                    }
                    
                    subscriptions[key] = try SubscriptionsInfoModel(json: value)
                }
            }
            
            if let data = attributes?["non_subscriptions"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? [Parameters] else {
                        continue
                    }
                    
                    var valuesArray = [NonSubscriptionsInfoModel]()
                    try value.forEach { (params) in
                        if let nonSubscriptionsInfoModel = try NonSubscriptionsInfoModel(json: params) { valuesArray.append(nonSubscriptionsInfoModel) }
                    }
                    nonSubscriptions[key] = valuesArray
                }
            }
        } catch {
            throw error
        }
        
        self.paidAccessLevels = paidAccessLevels
        self.subscriptions = subscriptions
        self.nonSubscriptions = nonSubscriptions
        self.appleValidationResult = attributes?["apple_validation_result"] as? Parameters
    }

}

public class PaidAccessLevelsInfoModel: JSONCodable {
    
    public var isActive: Bool
    public var vendorProductId: String
    public var store: String
    public var purchasedAt: Date
    public var renewedAt: Date?
    public var expiresAt: Date?
    public var isLifetime: Bool
    public var activeIntroductoryOfferType: String?
    public var activePromotionalOfferType: String?
    public var willRenew: Bool
    public var isInGracePeriod: Bool
    public var unsubscribedAt: Date?
    public var billingIssueDetectedAt: Date?
    
    required init?(json: Parameters) throws {
        guard
            let isActive = json["is_active"] as? Bool,
            let vendorProductId = json["vendor_product_id"] as? String,
            let store = json["store"] as? String,
            let purchasedAt = (json["purchased_at"] as? String)?.dateValue,
            let isLifetime = json["is_lifetime"] as? Bool,
            let willRenew = json["will_renew"] as? Bool,
            let isInGracePeriod = json["is_in_grace_period"] as? Bool
        else {
            throw SerializationError.missing("is_active, vendor_product_id, store, purchased_at, is_lifetime, will_renew, is_in_grace_period")
        }
        
        self.isActive = isActive
        self.vendorProductId = vendorProductId
        self.store = store
        self.purchasedAt = purchasedAt
        self.renewedAt = (json["renewed_at"] as? String)?.dateValue
        self.expiresAt = (json["expires_at"] as? String)?.dateValue
        self.isLifetime = isLifetime
        self.activeIntroductoryOfferType = json["active_introductory_offer_type"] as? String
        self.activePromotionalOfferType = json["active_promotional_offer_type"] as? String
        self.willRenew = willRenew
        self.isInGracePeriod = isInGracePeriod
        self.unsubscribedAt = (json["unsubscribed_at"] as? String)?.dateValue
        self.billingIssueDetectedAt = (json["billing_issue_detected_at"] as? String)?.dateValue
    }

}

public class SubscriptionsInfoModel: JSONCodable {
    
    public var isActive: Bool
    public var vendorProductId: String
    public var store: String
    public var purchasedAt: Date
    public var renewedAt: Date?
    public var expiresAt: Date?
    public var isLifetime: Bool
    public var activeIntroductoryOfferType: String?
    public var activePromotionalOfferType: String?
    public var willRenew: Bool
    public var isInGracePeriod: Bool
    public var unsubscribedAt: Date?
    public var billingIssueDetectedAt: Date?
    public var isSandbox: Bool
    
    required init?(json: Parameters) throws {
        guard
            let isActive = json["is_active"] as? Bool,
            let vendorProductId = json["vendor_product_id"] as? String,
            let store = json["store"] as? String,
            let purchasedAt = (json["purchased_at"] as? String)?.dateValue,
            let isLifetime = json["is_lifetime"] as? Bool,
            let willRenew = json["will_renew"] as? Bool,
            let isInGracePeriod = json["is_in_grace_period"] as? Bool,
            let isSandbox = json["is_sandbox"] as? Bool
        else {
            throw SerializationError.missing("is_active, vendor_product_id, store, purchased_at, is_lifetime, will_renew, is_in_grace_period, is_sandbox")
        }
        
        self.isActive = isActive
        self.vendorProductId = vendorProductId
        self.store = store
        self.purchasedAt = purchasedAt
        self.renewedAt = (json["renewed_at"] as? String)?.dateValue
        self.expiresAt = (json["expires_at"] as? String)?.dateValue
        self.isLifetime = isLifetime
        self.activeIntroductoryOfferType = json["active_introductory_offer_type"] as? String
        self.activePromotionalOfferType = json["active_promotional_offer_type"] as? String
        self.willRenew = willRenew
        self.isInGracePeriod = isInGracePeriod
        self.unsubscribedAt = (json["unsubscribed_at"] as? String)?.dateValue
        self.billingIssueDetectedAt = (json["billing_issue_detected_at"] as? String)?.dateValue
        self.isSandbox = isSandbox
    }

}

public class NonSubscriptionsInfoModel: JSONCodable {
    
    public var purchaseId: String
    public var vendorProductId: String
    public var store: String
    public var purchasedAt: Date
    public var isOneTime: Bool
    public var isSandbox: Bool
    
    required init?(json: Parameters) throws {
        guard
            let purchaseId = json["purchase_id"] as? String,
            let vendorProductId = json["vendor_product_id"] as? String,
            let store = json["store"] as? String,
            let purchasedAt = (json["purchased_at"] as? String)?.dateValue,
            let isOneTime = json["is_one_time"] as? Bool,
            let isSandbox = json["is_sandbox"] as? Bool
        else {
            throw SerializationError.missing("purchase_id, vendor_product_id, store, purchased_at, is_consumable, is_sandbox")
        }
        
        self.purchaseId = purchaseId
        self.vendorProductId = vendorProductId
        self.store = store
        self.purchasedAt = purchasedAt
        self.isOneTime = isOneTime
        self.isSandbox = isSandbox
    }

}
