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
    ) async throws(AdaptyError) -> VH<AdaptyProfile>

    func signSubscriptionOffer(
        profileId: String,
        vendorProductId: String,
        offerId: String
    ) async throws(AdaptyError) -> AdaptySubscriptionOffer.Signature
}

extension Adapty: PurchaseValidator {
    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
        case sk2Updates
    }

    func reportTransaction(
        profileId: String?,
        transactionId: String,
        variationId: String?
    ) async throws(AdaptyError) -> VH<AdaptyProfile> {
        do throws(HTTPError) {
            let response = try await httpSession.reportTransaction(
                profileId: profileId ?? profileStorage.profileId,
                transactionId: transactionId,
                variationId: variationId
            )
            saveResponse(response, syncedTransaction: true)
            return response
        } catch {
            throw error.asAdaptyError
        }
    }

    func validatePurchase(
        profileId: String?,
        transaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) -> VH<AdaptyProfile> {
        do throws(HTTPError) {
            let response = try await httpSession.validateTransaction(
                profileId: profileId ?? profileStorage.profileId,
                purchasedTransaction: transaction,
                reason: reason
            )
            saveResponse(response, syncedTransaction: true)
            return response
        } catch {
            throw error.asAdaptyError
        }
    }

    func signSubscriptionOffer(
        profileId: String,
        vendorProductId: String,
        offerId: String
    ) async throws(AdaptyError) -> AdaptySubscriptionOffer.Signature {
        do throws(HTTPError) {
            let response = try await httpSession.signSubscriptionOffer(
                profileId: profileId,
                vendorProductId: vendorProductId,
                offerId: offerId
            )
            return response
        } catch {
            throw error.asAdaptyError
        }
    }
}
