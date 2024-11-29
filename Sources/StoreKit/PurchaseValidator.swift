//
//  PurchaseValidator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation


protocol PurchaseValidator: AnyObject, Sendable {
    func validatePurchase(
        profileId: String?,
        transaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws -> VH<AdaptyProfile>

    func signSubscriptionOffer(
        profileId: String,
        vendorProductId: String,
        offerId: String
    ) async throws -> AdaptySubscriptionOffer.Signature
}


extension Adapty: PurchaseValidator {
    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
        case sk2Updates
    }
    
    func validatePurchase(
        profileId: String?,
        transaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws -> VH<AdaptyProfile> {
        do {
            let response = try await httpSession.validateTransaction(
                profileId: profileId ?? profileStorage.profileId,
                purchasedTransaction: transaction,
                reason: reason
            )
            saveResponse(response, syncedTrunsaction: true)
            return response
        } catch {
            throw error.asAdaptyError ?? AdaptyError.validatePurchaseFailed(unknownError: error)
        }
    }

    func signSubscriptionOffer(
        profileId: String,
        vendorProductId: String,
        offerId: String
    ) async throws -> AdaptySubscriptionOffer.Signature {
        do {
            let response = try await httpSession.signSubscriptionOffer(
                profileId: profileId,
                vendorProductId: vendorProductId,
                offerId: offerId
            )
            return response
        } catch {
            throw error.asAdaptyError ?? AdaptyError.signSubscriptionOfferFailed(unknownError: error)
        }
    }
}
