//
//  PurchaseValidator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation

protocol PurchaseValidator: AnyObject, Sendable {
    func validatePurchase_(
        userId: AdaptyUserId?,
        purchasedTransaction: PurchasedTransaction,
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
        userId: AdaptyUserId,
        transactionId: String,
        variationId: String?
    ) async throws(AdaptyError) -> VH<AdaptyProfile> {
        do {
            let response = try await httpSession.reportTransaction(
                userId: userId,
                transactionId: transactionId,
                variationId: variationId
            )
            saveResponse(response, syncedTransaction: true)
            return response
        } catch {
            throw error.asAdaptyError
        }
    }
    
    func reportTransaction(
        userId: AdaptyUserId,
        transaction: SKTransaction,
        variationId: String?
    ) async throws(AdaptyError) {

        let productOrNil = try? await productsManager.fetchProduct(
            id: transaction.unfProductID,
            fetchPolicy: .returnCacheDataElseLoad
        )

        _ = try await validatePurchase_(
            userId: userId,
            purchasedTransaction: .init(
                product: productOrNil,
                transaction: transaction,
                payload: .init(paywallVariationId: variationId)
            ),
            reason: .setVariation
        )
    }

    func validatePurchase_(
        userId: AdaptyUserId?,
        purchasedTransaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) -> VH<AdaptyProfile> {
        do {
            let response = try await httpSession.validateTransaction(
                userId: userId ?? profileStorage.userId,
                purchasedTransaction: purchasedTransaction,
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
