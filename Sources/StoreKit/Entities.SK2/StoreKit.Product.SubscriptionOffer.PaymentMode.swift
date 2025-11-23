//
//  StoreKit.Product.SubscriptionOffer.PaymentMode.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension StoreKit.Product.SubscriptionOffer.PaymentMode {
    var asPaymentMode: AdaptySubscriptionOffer.PaymentMode {
        switch self {
        case .payAsYouGo: .payAsYouGo
        case .payUpFront: .payUpFront
        case .freeTrial: .freeTrial
        default: .unknown
        }
    }
}
