//
//  ProductDiscount.PaymentMode.swift
//  Adapty
//
//  Created by Aleksei Valiano on 20.10.2022.
//

import Foundation
import StoreKit

extension ProductDiscount {
    public enum PaymentMode: UInt {
        case payAsYouGo
        case payUpFront
        case freeTrial
        case unknown
    }
}

extension ProductDiscount.PaymentMode {
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
}

extension ProductDiscount.PaymentMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .payAsYouGo: return "payAsYouGo"
        case .payUpFront: return "payUpFront"
        case .freeTrial: return "freeTrial"
        case .unknown: return "unknown"
        }
    }
}

extension ProductDiscount.PaymentMode: Equatable, Sendable {}

extension ProductDiscount.PaymentMode: Encodable {
    fileprivate enum CodingValues: String {
        case payAsYouGo = "pay_as_you_go"
        case payUpFront = "pay_up_front"
        case freeTrial = "free_trial"
        case unknown = "unknown"
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
