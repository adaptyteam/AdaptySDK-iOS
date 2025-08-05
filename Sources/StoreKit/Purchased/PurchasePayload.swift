//
//  PurchasePayload.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 08.09.2022.
//

import Foundation

struct PurchasePayload {
    let paywallVariationId: String?
    let persistentPaywallVariationId: String?
    let persistentOnboardingVariationId: String?

    init(
        paywallVariationId: String?,
        persistentPaywallVariationId: String? = nil,
        persistentOnboardingVariationId: String? = nil
    ) {
        self.paywallVariationId = paywallVariationId
        self.persistentPaywallVariationId = persistentPaywallVariationId
        self.persistentOnboardingVariationId = persistentOnboardingVariationId
    }
}
