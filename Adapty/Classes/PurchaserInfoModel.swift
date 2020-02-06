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
    public var paidAccessLevels: Parameters?
    public var subscriptions: Parameters?
    public var nonSubscriptions: Parameters?
    
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
        self.paidAccessLevels = attributes?["paid_access_levels"] as? Parameters
        self.subscriptions = attributes?["subscriptions"] as? Parameters
        self.nonSubscriptions = attributes?["non_subscriptions"] as? Parameters
    }

}
