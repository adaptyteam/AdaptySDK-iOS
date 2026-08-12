//
//  AdaptySubscriptionOffer.Identifier.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.01.2024.
//

import Foundation

package extension AdaptySubscriptionOffer {
    struct Identifier: Hashable {
        package let offerId: String?
        package let offerType: AdaptySubscriptionOfferType

        package init(
            offerId: String?,
            offerType: AdaptySubscriptionOfferType
        ) {
            self.offerId = offerId
            self.offerType = offerType
        }
    }
}

extension AdaptySubscriptionOffer.Identifier {
    @inlinable
    static var introductory: Self {
        .init(offerId: nil, offerType: .introductory)
    }

    @inlinable
    static func promotional(_ offerId: String) -> Self {
        .init(offerId: offerId, offerType: .promotional)
    }

    @inlinable
    static func winBack(_ offerId: String) -> Self {
        .init(offerId: offerId, offerType: .winBack)
    }

    @inlinable
    var promotionalOfferId: String? {
        offerType == .promotional ? offerId : nil
    }

    @inlinable
    var winBackOfferId: String? {
        offerType == .winBack ? offerId : nil
    }
}
