//
//  AdaptyProfile.SubscriptionCommitmentInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.09.2026.
//


import Foundation

public extension AdaptyProfile {
    struct SubscriptionCommitmentInfo: Sendable, Hashable {
        public let billingPeriodNumber: UInt
        public let totalBillingPeriods: UInt
        public let expiresAt: Date
    }
}

extension AdaptyProfile.SubscriptionCommitmentInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case billingPeriodNumber = "billing_period_number"
        case totalBillingPeriods = "total_billing_periods"
        case expiresAt = "expires_at"
    }
}
