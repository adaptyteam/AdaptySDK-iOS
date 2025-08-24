//
//  StoreKitTransactionSynchronizer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation

protocol StoreKitTransactionSynchronizer: AnyObject, Sendable {
    func report(
        purchasedTransaction: PurchasedTransaction,
        for userId: AdaptyUserId?,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError)

    func validate(
        purchasedTransaction: PurchasedTransaction,
        for: AdaptyUserId?
    ) async throws(AdaptyError) -> AdaptyProfile

    var currentProfileWithOfflineAccessLevels: AdaptyProfile? { get async }

}

extension Adapty: StoreKitTransactionSynchronizer {
    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
    }

    func sendTransactionId(
        _ transactionId: String,
        with variationId: String?,
        for userId: AdaptyUserId
    ) async throws(AdaptyError) {
        do {
            let response = try await httpSession.sendTransactionId(
                transactionId,
                with: variationId,
                for: userId
            )
            handleProfileResponse(response)
        } catch {
            throw error.asAdaptyError
        }
    }

    func report(
        purchasedTransaction: PurchasedTransaction,
        for userId: AdaptyUserId?,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) {
        do {
            let response = try await httpSession.validateTransaction(
                userId: userId ?? profileStorage.userId,
                purchasedTransaction: purchasedTransaction,
                reason: reason
            )
            handleTransactionResponse(response)
        } catch {
            throw error.asAdaptyError
        }
    }

    func validate(
        purchasedTransaction: PurchasedTransaction,
        for userId: AdaptyUserId?

    ) async throws(AdaptyError) -> AdaptyProfile {
        do {
            let response = try await httpSession.validateTransaction(
                userId: profileStorage.userId,
                purchasedTransaction: purchasedTransaction,
                reason: .purchasing
            )

            if let profile = await profileManager?.handleTransactionResponse(response) {
                return profile
            }
            return await profileWithOfflineAccessLevels(response.value)

        } catch {
            throw error.asAdaptyError
        }
    }

    var currentProfileWithOfflineAccessLevels: AdaptyProfile? {
        get async {
            await profileManager?.profileWithOfflineAccessLevels
        }
    }

 
}
