//
//  SK2Product.SubscriptionOffer.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension SK2Product.SubscriptionOffer.OfferType {
    var asOfferType: AdaptyProductDiscount.OfferType {
        switch self {
        case .introductory:
            return .introductory
        case .promotional:
            return .promotional
        default:
            #if compiler(>=6.0)
                if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *), type == .winBack {
                    return .winBack
                }
            #endif
            return .unknown
        }
    }
}
