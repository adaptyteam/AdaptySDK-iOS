//
//  PurchasePayload.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct PurchasePayload {
    let userId: AdaptyUserId
    let paywallVariationId: String?
    let persistentPaywallVariationId: String?
    let persistentOnboardingVariationId: String?
    
    init(
        userId: AdaptyUserId,
        paywallVariationId: String? = nil,
        persistentPaywallVariationId: String? = nil,
        persistentOnboardingVariationId: String? = nil
    ) {
        self.userId = userId
        self.paywallVariationId = paywallVariationId
        self.persistentPaywallVariationId = persistentPaywallVariationId
        self.persistentOnboardingVariationId = persistentOnboardingVariationId
    }
}

extension PurchasePayload: Codable {
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case paywallVariationId = "paywall_variation_id"
        case persistentPaywallVariationId = "persistent_paywall_variation_id"
        case persistentOnboardingVariationId = "onboarding_variation_id"
    }
}
