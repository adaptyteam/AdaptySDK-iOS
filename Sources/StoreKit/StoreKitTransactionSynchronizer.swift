//
//  StoreKitTransactionSynchronizer.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation

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

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func finish(
        transaction: SK2Transaction,
        recived: TransactionRecivedBy
    ) async

    func recalculateOfflineAccessLevels(with: SKTransaction) async -> AdaptyProfile?
}

enum TransactionRecivedBy {
    case updates
    case purchased
    case unfinished
    case manual
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

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    func finish(
        transaction: SK2Transaction,
        recived _: TransactionRecivedBy
    ) async {
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
