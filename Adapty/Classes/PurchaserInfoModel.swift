//
//  PurchaserInfoModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 04/02/2020.
//

import Foundation

public class PurchaserInfoModel: NSObject, JSONCodable, Codable {

    var profileId: String
    @objc public var customerUserId: String?
    @objc public var accessLevels: [String: AccessLevelInfoModel]
    @objc public var subscriptions: [String: SubscriptionInfoModel]
    @objc public var nonSubscriptions: [String: [NonSubscriptionInfoModel]]
    
    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let profileId = attributes?["id"] as? String
        else {
            throw AdaptyError.missingParam("PurchaserInfoModel - id")
        }
        
        self.profileId = profileId
        self.customerUserId = attributes?["customer_user_id"] as? String
        
        var accessLevels = [String: AccessLevelInfoModel]()
        var subscriptions = [String: SubscriptionInfoModel]()
        var nonSubscriptions = [String: [NonSubscriptionInfoModel]]()
        do {
            if let data = attributes?["paid_access_levels"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? Parameters else {
                        continue
                    }
                    
                    accessLevels[key] = try AccessLevelInfoModel(json: value)
                }
            }
            
            if let data = attributes?["subscriptions"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? Parameters else {
                        continue
                    }
                    
                    subscriptions[key] = try SubscriptionInfoModel(json: value)
                }
            }
            
            if let data = attributes?["non_subscriptions"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? [Parameters] else {
                        continue
                    }
                    
                    var valuesArray = [NonSubscriptionInfoModel]()
                    try value.forEach { (params) in
                        if let nonSubscriptionInfoModel = try NonSubscriptionInfoModel(json: params) { valuesArray.append(nonSubscriptionInfoModel) }
                    }
                    nonSubscriptions[key] = valuesArray
                }
            }
        } catch {
            throw error
        }
        
        self.accessLevels = accessLevels
        self.subscriptions = subscriptions
        self.nonSubscriptions = nonSubscriptions
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PurchaserInfoModel else {
            return false
        }
        
        return self.profileId == object.profileId && self.customerUserId == object.customerUserId && self.accessLevels == object.accessLevels && self.subscriptions == object.subscriptions && self.nonSubscriptions == object.nonSubscriptions
    }

}

public class AccessLevelInfoModel: NSObject, JSONCodable, Codable {
    
    @objc public var id: String
    @objc public var isActive: Bool
    @objc public var vendorProductId: String
    @objc public var store: String
    @objc public var activatedAt: Date?
    @objc public var renewedAt: Date?
    @objc public var expiresAt: Date?
    @objc public var isLifetime: Bool
    @objc public var activeIntroductoryOfferType: String?
    @objc public var activePromotionalOfferType: String?
    @objc public var willRenew: Bool
    @objc public var isInGracePeriod: Bool
    @objc public var unsubscribedAt: Date?
    @objc public var billingIssueDetectedAt: Date?
    @objc public var vendorTransactionId: String?
    @objc public var vendorOriginalTransactionId: String?
    @objc public var startsAt: Date?
    @objc public var cancellationReason: String?
    @objc public var isRefund: Bool
    
    required init?(json: Parameters) throws {
        guard
            let id = json["id"] as? String,
            let isActive = json["is_active"] as? Bool
        else {
            throw AdaptyError.missingParam("AccessLevelInfoModel - id, is_active")
        }
        
        self.id = id
        self.isActive = isActive
        self.vendorProductId = json["vendor_product_id"] as? String ?? ""
        self.store = json["store"] as? String ?? ""
        self.activatedAt = (json["activated_at"] as? String)?.dateValue
        self.renewedAt = (json["renewed_at"] as? String)?.dateValue
        self.expiresAt = (json["expires_at"] as? String)?.dateValue
        self.isLifetime = json["is_lifetime"] as? Bool ?? false
        self.activeIntroductoryOfferType = json["active_introductory_offer_type"] as? String
        self.activePromotionalOfferType = json["active_promotional_offer_type"] as? String
        self.willRenew = json["will_renew"] as? Bool ?? false
        self.isInGracePeriod = json["is_in_grace_period"] as? Bool ?? false
        self.unsubscribedAt = (json["unsubscribed_at"] as? String)?.dateValue
        self.billingIssueDetectedAt = (json["billing_issue_detected_at"] as? String)?.dateValue
        self.vendorTransactionId = json["vendor_transaction_id"] as? String
        self.vendorOriginalTransactionId = json["vendor_original_transaction_id"] as? String
        self.startsAt = (json["starts_at"] as? String)?.dateValue
        self.cancellationReason = json["cancellation_reason"] as? String
        self.isRefund = json["is_refund"] as? Bool ?? false
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? AccessLevelInfoModel else {
            return false
        }
        
        return self.id == object.id && self.isActive == object.isActive && self.vendorProductId == object.vendorProductId && self.store == object.store && self.activatedAt == object.activatedAt && self.renewedAt == object.renewedAt && self.expiresAt == object.expiresAt && self.isLifetime == object.isLifetime && self.activeIntroductoryOfferType == object.activeIntroductoryOfferType && self.activePromotionalOfferType == object.activePromotionalOfferType && self.willRenew == object.willRenew && self.isInGracePeriod == object.isInGracePeriod && self.unsubscribedAt == object.unsubscribedAt && self.billingIssueDetectedAt == object.billingIssueDetectedAt && self.vendorTransactionId == object.vendorTransactionId && self.vendorOriginalTransactionId == object.vendorOriginalTransactionId && self.startsAt == object.startsAt && self.cancellationReason == object.cancellationReason && self.isRefund == object.isRefund
    }

}

public class SubscriptionInfoModel: NSObject, JSONCodable, Codable {
    
    @objc public var isActive: Bool
    @objc public var vendorProductId: String
    @objc public var store: String
    @objc public var activatedAt: Date?
    @objc public var renewedAt: Date?
    @objc public var expiresAt: Date?
    @objc public var startsAt: Date?
    @objc public var isLifetime: Bool
    @objc public var activeIntroductoryOfferType: String?
    @objc public var activePromotionalOfferType: String?
    @objc public var willRenew: Bool
    @objc public var isInGracePeriod: Bool
    @objc public var unsubscribedAt: Date?
    @objc public var billingIssueDetectedAt: Date?
    @objc public var isSandbox: Bool
    @objc public var vendorTransactionId: String?
    @objc public var vendorOriginalTransactionId: String?
    @objc public var cancellationReason: String?
    @objc public var isRefund: Bool
    
    required init?(json: Parameters) throws {
        guard
            let isActive = json["is_active"] as? Bool,
            let vendorProductId = json["vendor_product_id"] as? String
        else {
            throw AdaptyError.missingParam("SubscriptionInfoModel - is_active, vendor_product_id")
        }
        
        self.isActive = isActive
        self.vendorProductId = vendorProductId
        self.store = json["store"] as? String ?? ""
        self.activatedAt = (json["activated_at"] as? String)?.dateValue
        self.renewedAt = (json["renewed_at"] as? String)?.dateValue
        self.expiresAt = (json["expires_at"] as? String)?.dateValue
        self.startsAt = (json["starts_at"] as? String)?.dateValue
        self.isLifetime = json["is_lifetime"] as? Bool ?? false
        self.activeIntroductoryOfferType = json["active_introductory_offer_type"] as? String
        self.activePromotionalOfferType = json["active_promotional_offer_type"] as? String
        self.willRenew = json["will_renew"] as? Bool ?? false
        self.isInGracePeriod = json["is_in_grace_period"] as? Bool ?? false
        self.unsubscribedAt = (json["unsubscribed_at"] as? String)?.dateValue
        self.billingIssueDetectedAt = (json["billing_issue_detected_at"] as? String)?.dateValue
        self.isSandbox = json["is_sandbox"] as? Bool ?? false
        self.vendorTransactionId = json["vendor_transaction_id"] as? String
        self.vendorOriginalTransactionId = json["vendor_original_transaction_id"] as? String
        self.cancellationReason = json["cancellation_reason"] as? String
        self.isRefund = json["is_refund"] as? Bool ?? false
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SubscriptionInfoModel else {
            return false
        }
        
        return self.isActive == object.isActive && self.vendorProductId == object.vendorProductId && self.store == object.store && self.activatedAt == object.activatedAt && self.renewedAt == object.renewedAt && self.expiresAt == object.expiresAt && self.startsAt == object.startsAt && self.isLifetime == object.isLifetime && self.activeIntroductoryOfferType == object.activeIntroductoryOfferType && self.activePromotionalOfferType == object.activePromotionalOfferType && self.willRenew == object.willRenew && self.isInGracePeriod == object.isInGracePeriod && self.unsubscribedAt == object.unsubscribedAt && self.billingIssueDetectedAt == object.billingIssueDetectedAt && self.isSandbox == object.isSandbox && self.vendorTransactionId == object.vendorTransactionId && self.vendorOriginalTransactionId == object.vendorOriginalTransactionId && self.cancellationReason == object.cancellationReason && self.isRefund == object.isRefund
    }

}

public class NonSubscriptionInfoModel: NSObject, JSONCodable, Codable {
    
    @objc public var purchaseId: String
    @objc public var vendorProductId: String
    @objc public var store: String
    @objc public var purchasedAt: Date?
    @objc public var isOneTime: Bool
    @objc public var isSandbox: Bool
    @objc public var vendorTransactionId: String?
    @objc public var vendorOriginalTransactionId: String?
    @objc public var isRefund: Bool
    
    required init?(json: Parameters) throws {
        guard
            let purchaseId = json["purchase_id"] as? String,
            let vendorProductId = json["vendor_product_id"] as? String
        else {
            throw AdaptyError.missingParam("NonSubscriptionInfoModel - purchase_id, vendor_product_id")
        }
        
        self.purchaseId = purchaseId
        self.vendorProductId = vendorProductId
        self.store = json["store"] as? String ?? ""
        self.purchasedAt = (json["purchased_at"] as? String)?.dateValue
        self.isOneTime = json["is_one_time"] as? Bool ?? false
        self.isSandbox = json["is_sandbox"] as? Bool ?? false
        self.vendorTransactionId = json["vendor_transaction_id"] as? String
        self.vendorOriginalTransactionId = json["vendor_original_transaction_id"] as? String
        self.isRefund = json["is_refund"] as? Bool ?? false
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? NonSubscriptionInfoModel else {
            return false
        }
        
        return self.purchaseId == object.purchaseId && self.vendorProductId == object.vendorProductId && self.store == object.store && self.purchasedAt == object.purchasedAt && self.isOneTime == object.isOneTime && self.isSandbox == object.isSandbox && self.vendorTransactionId == object.vendorTransactionId && self.vendorOriginalTransactionId == object.vendorOriginalTransactionId && self.isRefund == object.isRefund
    }

}

class PurchaserInfoMeta: JSONCodable {
    
    var purchaserInfo: PurchaserInfoModel?
    var appleValidationResult: Parameters?
    
    required init?(json: Parameters) throws {
        do {
            self.purchaserInfo = try PurchaserInfoModel(json: json)
        } catch {
            throw AdaptyError.invalidProperty("PurchaserInfoMeta - purchaser_info", json)
        }
        
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        self.appleValidationResult = attributes?["apple_validation_result"] as? Parameters
    }
    
}
