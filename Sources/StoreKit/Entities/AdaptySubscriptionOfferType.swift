//
//  AdaptySubscriptionOfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.08.2025.
//

import Foundation
import StoreKit

public struct AdaptySubscriptionOfferType: Sendable, RawRepresentable, Equatable, Hashable {
    public let rawValue: String

    @inlinable
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let introductory = AdaptySubscriptionOfferType(rawValue: "introductory")
    public static let promotional = AdaptySubscriptionOfferType(rawValue: "promotional")
    public static let winBack = AdaptySubscriptionOfferType(rawValue: "win_back")
}
