//
//  PurchasePayload.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct PurchasePayload: Sendable, Hashable {
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

extension PurchasePayload {
    var logParams: EventParameters {
        [
            "user_id": userId,
            "variation_id": paywallVariationId,
            "persited_variation_id": persistentPaywallVariationId,
            "onboarding_variation_id": persistentOnboardingVariationId
        ].removeNil
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
