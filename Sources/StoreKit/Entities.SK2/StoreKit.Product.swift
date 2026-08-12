//
//  StoreKit.Product.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 01.02.2024
//

import StoreKit

extension StoreKit.Product {
    var asAdaptyProduct: AdaptyProduct {
        AdaptyProductWrapper(skProduct: self)
    }
}

private struct AdaptyProductWrapper: AdaptyProduct {
    let skProduct: StoreKit.Product
}

extension StoreKit.Product {
    var introductoryOfferNotApplicable: Bool {
        subscription?.introductoryOffer == nil
    }

    func subscriptionOffer(by offerId: String?, for offerType: AdaptyTransactionOfferType) -> SubscriptionOffer? {
        switch offerType {
        case .introductory:
            return subscription?.introductoryOffer
        case .promotional:
            guard let offerId else { return nil }
            return subscription?.promotionalOffers.first(where: { $0.id == offerId })
        case .winBack:
            guard
                #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *),
                let offerId
            else { return nil }
            return subscription?.winBackOffers.first { $0.id == offerId }
        default:
            return nil
        }
    }

    func subscriptionOffer(by offerId: String?, for offerType: AdaptySubscriptionOfferType) -> SubscriptionOffer? {
        switch offerType {
        case .introductory:
            return subscription?.introductoryOffer
        case .promotional:
            guard let offerId else { return nil }
            return subscription?.promotionalOffers.first(where: { $0.id == offerId })
        case .winBack:
            guard
                #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *),
                let offerId
            else { return nil }
            return subscription?.winBackOffers.first { $0.id == offerId }
        default:
            return nil
        }
    }

    func subscriptionOffer(by offerIdentifier: AdaptySubscriptionOffer.Identifier) -> SubscriptionOffer? {
        subscriptionOffer(by: offerIdentifier.offerId, for: offerIdentifier.offerType)
    }
}
