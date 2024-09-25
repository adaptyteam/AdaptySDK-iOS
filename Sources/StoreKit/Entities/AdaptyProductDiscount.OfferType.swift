//
//  AdaptyProductDiscount.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.01.2024.
//

import Foundation

extension AdaptyProductDiscount {
    public enum OfferType: String, Sendable {
        case introductory
        case promotional
        case winBack
        case unknown
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
