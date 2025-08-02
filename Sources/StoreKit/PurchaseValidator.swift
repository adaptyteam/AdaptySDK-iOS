//
//  PurchaseValidator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation

protocol PurchaseValidator: AnyObject, Sendable {
    func validatePurchase(
        userId: AdaptyUserId?,
        transaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) -> VH<AdaptyProfile>

    func signSubscriptionOffer(
        userId: AdaptyUserId,
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
        userId: AdaptyUserId?,
        transactionId: String,
        variationId: String?
    ) async throws(AdaptyError) -> VH<AdaptyProfile> {
        do {
            let response = try await httpSession.reportTransaction(
                userId: userId ?? profileStorage.userId,
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
        userId: AdaptyUserId?,
        transaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) -> VH<AdaptyProfile> {
        do {
            let response = try await httpSession.validateTransaction(
                userId: userId ?? profileStorage.userId,
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
        userId: AdaptyUserId,
        vendorProductId: String,
        offerId: String
    ) async throws(AdaptyError) -> AdaptySubscriptionOffer.Signature {
        do {
            let response = try await httpSession.signSubscriptionOffer(
                userId: userId,
                vendorProductId: vendorProductId,
                offerId: offerId
            )
            return response
        } catch {
            throw error.asAdaptyError
        }
    }
}
