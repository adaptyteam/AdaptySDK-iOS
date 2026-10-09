//
//  AdaptySubscriptionBillingPlan.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 18.09.2026.
//

import Foundation
import StoreKit

public struct AdaptySubscriptionBillingPlan: Sendable, RawRepresentable, Equatable, Hashable {
    public let rawValue: String

    @inlinable
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let upFront = AdaptySubscriptionBillingPlan(rawValue: "up_front")
    public static let monthly = AdaptySubscriptionBillingPlan(rawValue: "monthly")
}

extension AdaptySubscriptionBillingPlan: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension AdaptySubscriptionBillingPlan: Codable { }
