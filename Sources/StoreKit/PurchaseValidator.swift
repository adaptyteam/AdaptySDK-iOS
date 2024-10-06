//
//  PurchaseValidator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.10.2024
//

import Foundation

protocol PurchaseValidator: Sendable {
    func validatePurchase(
        profileId: String?,
        transaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason
    ) async throws -> VH<AdaptyProfile>
}

enum ValidatePurchaseReason {
    case setVariation
    case observing
    case purchasing
}

extension Adapty: PurchaseValidator {
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
}
