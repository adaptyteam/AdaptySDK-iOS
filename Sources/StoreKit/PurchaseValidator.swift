//
//  PurchaseValidator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation

protocol PurchaseValidator: AnyObject, Sendable {
    func reportTransaction(
        userId: AdaptyUserId?,
        purchasedTransaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError)

    func validatePurchase(
        _: PurchasedTransaction
    ) async throws(AdaptyError) -> (AdaptyProfile, finishTransaction: Bool)

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
    }

    func reportTransaction(
        userId: AdaptyUserId,
        transactionId: String,
        variationId: String?
    ) async throws(AdaptyError) {
        do {
            let response = try await httpSession.reportTransaction(
                userId: userId,
                transactionId: transactionId,
                variationId: variationId
            )

            profileManager?.handleProfileResponse(response)

        } catch {
            throw error.asAdaptyError
        }
    }

    func reportTransaction(
        userId: AdaptyUserId?,
        purchasedTransaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) {
        do {
            let response = try await httpSession.validateTransaction(
                userId: userId ?? profileStorage.userId,
                purchasedTransaction: purchasedTransaction,
                reason: reason
            )

            profileManager?.handleTransactionResponse(response)
        } catch {
            throw error.asAdaptyError
        }
    }

    func validatePurchase(
        _ purchasedTransaction: PurchasedTransaction
    ) async throws(AdaptyError) -> (AdaptyProfile, finishTransaction: Bool) {
        do {
            let response = try await httpSession.validateTransaction(
                userId: profileStorage.userId,
                purchasedTransaction: purchasedTransaction,
                reason: .purchasing
            )

            let profile = profileManager?.handleTransactionResponse(response)

            return (
                profile ?? profileWithOfflineAccessLevels(response.value),
                finishTransaction: true
            )

        } catch {
            if let profile = profileManager?.currentProfileWithOfflineAccessLevelsIfFeatureAvailable {
                return (profile, finishTransaction: false)
            } else {
                throw error.asAdaptyError
            }
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
