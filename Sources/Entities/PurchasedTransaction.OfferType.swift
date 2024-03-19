//
//  PurchasedTransaction.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.01.2024.
//

import Foundation
import StoreKit

extension PurchasedTransaction {
    enum OfferType: Int {
        case introductory
        case promotional
        case code
        case unknown
    }
}

extension PurchasedTransaction.OfferType {
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    init(type: SK2Transaction.OfferType) {
        self =
            switch type {
            case .introductory: .introductory
            case .promotional: .promotional
            case .code: .code
            default: .unknown
            }
    }
}

extension PurchasedTransaction.OfferType: Equatable, Sendable {}

extension PurchasedTransaction.OfferType: Encodable {
    private enum CodingValues: String {
        case introductory
        case promotional
        case code
        case unknown
    }

    func encode(to encoder: Encoder) throws {
        let value: CodingValues =
            switch self {
            case .introductory: .introductory
            case .promotional: .promotional
            case .code: .code
            case .unknown: .unknown
            }

        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
