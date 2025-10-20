//
//  AdaptySubscriptionOfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 05.08.2025.
//

import StoreKit

public enum AdaptySubscriptionOfferType: String, Sendable {
    case introductory
    case promotional
    case winBack = "win_back"
    case code
}

extension AdaptySubscriptionOfferType: Codable {}

extension SK1Product.SubscriptionOffer.OfferType {
    var asSubscriptionOfferType: AdaptySubscriptionOfferType? {
        switch self {
        case .introductory: .introductory
        case .subscription: .promotional
        default: nil
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Transaction.OfferType {
    var asSubscriptionOfferType: AdaptySubscriptionOfferType? {
        switch self {
        case .introductory: .introductory
        case .promotional: .promotional
        case .winBack: .winBack
        case .code: .code
        default: nil
        }
    }
}
