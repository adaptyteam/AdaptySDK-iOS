//
//  PurchasedTransaction.OfferType.swift
//  Adapty
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
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    init(type: SK2Transaction.OfferType) {
        switch type {
        case .introductory:
            self = .introductory
        case .promotional:
            self = .promotional
        case .code:
            self = .code
        default:
            self = .unknown
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
        let value: CodingValues
        switch self {
        case .introductory: value = .introductory
        case .promotional: value = .promotional
        case .code: value = .code
        case .unknown: value = .unknown
        }

        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
