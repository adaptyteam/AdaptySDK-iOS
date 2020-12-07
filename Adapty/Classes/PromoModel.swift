//
//  PromoModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 22/04/2020.
//

import Foundation

public class PromoModel: NSObject, JSONCodable, Codable {
    
    @objc public var promoType: String
    @objc public var variationId: String
    @objc public var expiresAt: Date?
    @objc public var paywall: PaywallModel?
    
    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }
        
        guard
            let promoType = attributes?["promo_type"] as? String,
            let variationId = attributes?["variation_id"] as? String
        else {
            throw AdaptyError.missingParam("PromoModel - promo_type, variation_id")
        }
        
        self.promoType = promoType
        self.variationId = variationId
        self.expiresAt = (attributes?["expires_at"] as? String)?.dateValue
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PromoModel else {
            return false
        }
        
        return self.promoType == object.promoType && self.variationId == object.variationId && self.expiresAt == object.expiresAt && self.paywall == object.paywall
    }
    
}
