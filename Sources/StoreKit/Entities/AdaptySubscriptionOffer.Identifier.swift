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

private extension AdaptySubscriptionOffer.Identifier {
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

extension SK2Transaction {
    var subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier? {
        guard let offerType = subscriptionOfferType else { return nil }
        return .init(offerId: unfOfferId, offerType: offerType)
    }
}

@available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, visionOS 1.1, *)
extension SK2Transaction.Offer {
    var subscriptionOfferIdentifier: AdaptySubscriptionOffer.Identifier? {
        guard let offerType = type.asSubscriptionOfferType else { return nil }
        return .init(offerId: id, offerType: offerType)
    }
}
