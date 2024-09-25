//
//  SK1Product.SubscriptionOffer.PaymentMode.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

extension SK1Product.SubscriptionOffer.PaymentMode {
    var asPaymentMode: AdaptyProductDiscount.PaymentMode {
        switch self {
        case .payAsYouGo:
            .payAsYouGo
        case .payUpFront:
            .payUpFront
        case .freeTrial:
            .freeTrial
        @unknown default:
            .unknown
        }
    }
}
