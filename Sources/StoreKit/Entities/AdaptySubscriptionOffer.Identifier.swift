//
//  AdaptySubscriptionOffer.Identifier.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.01.2024.
//

import Foundation

package extension AdaptySubscriptionOffer {
    enum Identifier: Sendable, Hashable {
        case introductory
        case promotional(String)
        case winBack(String)
        case code(String?)

        package var offerId: String? {
            switch self {
            case .introductory: nil
            case let .promotional(value),
                 let .winBack(value): value
            case let .code(value): value
            }
        }

        package var offerType: AdaptySubscriptionOfferType {
            switch self {
            case .introductory: .introductory
            case .promotional: .promotional
            case .winBack: .winBack
            case .code: .code
            }
        }
    }
}

extension AdaptySubscriptionOffer.Identifier {
    init?(offerId: String?, offerType: AdaptySubscriptionOfferType) {
        switch offerType {
        case .introductory:
            self = .introductory
        case .promotional:
            guard let offerId else { return nil }
            self = .promotional(offerId)
        case .winBack:
            guard let offerId else { return nil }
            self = .winBack(offerId)
        case .code:
            self = .code(offerId)
        }
    }
}
