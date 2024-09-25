//
//  SK1Product.SubscriptionOffer.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//  

import StoreKit

extension SK1Product.SubscriptionOffer {
    typealias OfferType = `Type`
}

extension SK1Product.SubscriptionOffer.OfferType {
    var asOfferType: AdaptyProductDiscount.OfferType {
        switch self {
        case .introductory:
            .introductory
        case .subscription:
            .promotional
        @unknown default:
            .unknown
        }
    }
}
