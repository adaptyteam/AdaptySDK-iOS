//
//  StoreKit.Transaction.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.11.2025.
//

import StoreKit

extension StoreKit.Transaction.OfferType {
    var asAdaptyTransactionOfferType: AdaptyTransactionOfferType {
        switch self {
        case .introductory: .introductory
        case .promotional: .promotional
        case .code: .code
        case .winBack: .winBack
        default: .init(rawValue: rawValue)
        }
    }
}

extension AdaptyTransactionOfferType {
    var asAdaptySubscriptionOfferType: AdaptySubscriptionOfferType? {
        switch self {
        case .introductory: .introductory
        case .promotional: .promotional
        case .winBack: .winBack
        default: nil
        }
    }
}
