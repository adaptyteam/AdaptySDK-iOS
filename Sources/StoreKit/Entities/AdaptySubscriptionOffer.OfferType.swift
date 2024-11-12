//
//  AdaptySubscriptionOffer.OfferType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.01.2024.
//

import Foundation

extension AdaptySubscriptionOffer {
   package enum OfferTypeWithIdentifier: Sendable, Hashable {
        case introductory
        case promotional(String)
        case winBack(String)

        var identifier: String? {
            switch self {
            case .introductory:
                nil
            case let .promotional(value),
                 let .winBack(value):
                value
            }
        }

        var asOfferType: OfferType {
            switch self {
            case .introductory:
                .introductory
            case .promotional:
                .promotional
            case .winBack:
                .winBack
            }
        }
    }

    public enum OfferType: String, Sendable {
        case introductory
        case promotional
        case winBack
    }
}

