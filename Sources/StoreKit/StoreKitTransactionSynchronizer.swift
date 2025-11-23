//
//  StoreKitTransactionSynchronizer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation
import StoreKit

@AdaptyActor
protocol StoreKitTransactionSynchronizer: AnyObject, Sendable {
    func report(
        _: PurchasedTransactionInfo,
        payload: PurchasePayload,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError)

    func validate(
        _: PurchasedTransactionInfo,
        payload: PurchasePayload
    ) async throws(AdaptyError) -> AdaptyProfile

    func attemptToFinish(transaction: StoreKit.Transaction, logSource: String) async

    func finish(transaction: StoreKit.Transaction) async

    func recalculateOfflineAccessLevels() async -> AdaptyProfile
}

extension Adapty: StoreKitTransactionSynchronizer {
    enum ValidatePurchaseReason: Sendable, Hashable {
        case setVariation
        case observing
        case purchasing
        case unfinished
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

    func attemptToFinish(transaction: StoreKit.Transaction, logSource: String) async {
        if await purchasePayloadStorage.canFinishSyncedTransaction(transaction.unfIdentifier) {
            await finish(transaction: transaction)
            Log.transactionManager.info("Finish \(logSource) transaction: \(transaction) for product: \(transaction.unfProductId)")
        } else {
            Log.transactionManager.info("Successfully \(logSource) transaction synced: \(transaction), manual finish required for product: \(transaction.unfProductId)")
        }
    }

    func finish(transaction: StoreKit.Transaction) async {
        await transaction.finish()
        await purchasePayloadStorage.removePurchasePayload(forTransaction: transaction)
        await purchasePayloadStorage.removeUnfinishedTransaction(transaction.unfIdentifier)
        Adapty.trackSystemEvent(AdaptyAppleRequestParameters(
            methodName: .finishTransaction,
            params: transaction.logParams
        ))
    }

    func report(
        _ transactionInfo: PurchasedTransactionInfo,
        payload: PurchasePayload,
        reason: Adapty.ValidatePurchaseReason
    ) async throws(AdaptyError) {
        do {
            let response = try await httpSession.validateTransaction(
                transactionInfo: transactionInfo,
                payload: payload,
                reason: reason
            )
            handleTransactionResponse(response)
        } catch {
            throw error.asAdaptyError
        }
    }

    func validate(
        _ transactionInfo: PurchasedTransactionInfo,
        payload: PurchasePayload
    ) async throws(AdaptyError) -> AdaptyProfile {
        do {
            let response = try await httpSession.validateTransaction(
                transactionInfo: transactionInfo,
                payload: payload,
                reason: .purchasing
            )
            handleTransactionResponse(response)
            return await profileWithOfflineAccessLevels(response.value)
        } catch {
            throw error.asAdaptyError
        }
    }
}
