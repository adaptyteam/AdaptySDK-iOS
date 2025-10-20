//
//  StoreKitSubscriptionOfferSigner.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 14.08.2025.
//

import Foundation

protocol StoreKitSubscriptionOfferSigner: AnyObject, Sendable {
    func sign(
        offerId: String,
        subscriptionVendorId: String,
        for userId: AdaptyUserId
    ) async throws(AdaptyError) -> AdaptySubscriptionOffer.Signature
}

extension Adapty: StoreKitSubscriptionOfferSigner {
    func sign(
        offerId: String,
        subscriptionVendorId: String,
        for userId: AdaptyUserId
    ) async throws(AdaptyError) -> AdaptySubscriptionOffer.Signature {
        do {
            let response = try await httpSession.signSubscriptionOffer(
                userId: userId,
                vendorProductId: subscriptionVendorId,
                offerId: offerId
            )
            return response
        } catch {
            throw error.asAdaptyError
        }
    }
}
