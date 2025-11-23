//
//  StoreKit.Transaction.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.11.2025.
//

import StoreKit

extension StoreKit.Transaction.OfferType {
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
