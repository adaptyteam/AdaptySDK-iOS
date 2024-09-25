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
        case unknown = 0
        case introductory = 1
        case promotional = 2
        case code = 3
        case winBack = 4
    }
}

extension PurchasedTransaction.OfferType: Encodable {
    private enum CodingValues: String {
        case introductory
        case promotional
        case code
        case winBack = "win_back"
        case unknown
    }

    func encode(to encoder: Encoder) throws {
        let value: CodingValues =
            switch self {
            case .introductory: .introductory
            case .promotional: .promotional
            case .code: .code
            case .winBack: .winBack
            case .unknown: .unknown
            }

        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}
