//
//  AdaptyProductDiscount.PaymentMode.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation
import StoreKit

extension AdaptyProductDiscount {
    public enum PaymentMode: UInt {
        case payAsYouGo
        case payUpFront
        case freeTrial
        case unknown
    }
}

extension AdaptyProductDiscount.PaymentMode {
    @available(iOS 11.2, macOS 10.14.4, *)
    public init(mode: SKProductDiscount.PaymentMode) {
        switch mode {
        case .payAsYouGo:
            self = .payAsYouGo
        case .payUpFront:
            self = .payUpFront
        case .freeTrial:
            self = .freeTrial
        @unknown default:
            self = .unknown
        }
    }

    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public init(mode: Product.SubscriptionOffer.PaymentMode) {
        switch mode {
        case .payAsYouGo:
            self = .payAsYouGo
        case .payUpFront:
            self = .payUpFront
        case .freeTrial:
            self = .freeTrial
        default:
            self = .unknown
        }
    }
}

extension AdaptyProductDiscount.PaymentMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .payAsYouGo: return "payAsYouGo"
        case .payUpFront: return "payUpFront"
        case .freeTrial: return "freeTrial"
        case .unknown: return "unknown"
        }
    }
}

extension AdaptyProductDiscount.PaymentMode: Equatable, Sendable {}

extension AdaptyProductDiscount.PaymentMode: Encodable {
    fileprivate enum CodingValues: String {
        case payAsYouGo = "pay_as_you_go"
        case payUpFront = "pay_up_front"
        case freeTrial = "free_trial"
        case unknown
    }

    public func encode(to encoder: Encoder) throws {
        let value: CodingValues
        switch self {
        case .payAsYouGo: value = .payAsYouGo
        case .payUpFront: value = .payUpFront
        case .freeTrial: value = .freeTrial
        case .unknown: value = .unknown
        }

        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
