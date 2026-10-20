//
//  AdaptyFlowPaywall.ProductPricingTerms.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.09.2026.
//


import Foundation

extension AdaptyFlowPaywall {
    struct ProducPricingTerms: Sendable, Hashable, Equatable {
        static let `default` = Self(billingPlan: .upFront, promotionalOfferId: nil, winBackOfferId: nil)

        let billingPlan: AdaptySubscriptionBillingPlan
        let promotionalOfferId: String?
        let winBackOfferId: String?
    }
}

extension AdaptyFlowPaywall.ProducPricingTerms: CustomStringConvertible {
    var description: String {
        "(billingPlan: \(billingPlan), promotionalOfferId: \(promotionalOfferId, default: "nil"), winBackOfferId: \(winBackOfferId, default: "nil"))"
    }
}

extension AdaptyFlowPaywall.ProducPricingTerms: Codable {
    enum CodingKeys: String, CodingKey {
        case billingPlan = "billing_plan_id"
        case promotionalOfferId = "promotional_offer_id"
        case winBackOfferId = "win_back_offer_id"
    }
}
