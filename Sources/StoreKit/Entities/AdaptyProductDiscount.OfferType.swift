//
//  AdaptyProductDiscount.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.01.2024.
//

import Foundation
import StoreKit

extension AdaptyProductDiscount {
    public enum OfferType: String, Sendable {
        case introductory
        case promotional
        case winBack
        case unknown
    }
}

extension AdaptyProductDiscount.OfferType {
    init(type: SK1Product.SubscriptionOffer.OfferType) {
        self =
            switch type {
            case .introductory:
                .introductory
            case .subscription:
                .promotional
            @unknown default:
                .unknown
            }
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(type: SK2Product.SubscriptionOffer.OfferType) {
        switch type {
        case .introductory:
            self = .introductory
        case .promotional:
            self = .promotional
        default:
            #if swift(>=6.0)
                if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *), type == .winBack {
                    self = .winBack
                    return
                }
            #endif
            self = .unknown
        }
    }
}

extension AdaptyProductDiscount.OfferType: Encodable {
    public func encode(to encoder: Encoder) throws {
        let value: PurchasedTransaction.OfferType =
            switch self {
            case .introductory: .introductory
            case .promotional: .promotional
            case .winBack: .winBack
            case .unknown: .unknown
            }

        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
