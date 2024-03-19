//
//  Adapty+PurchaseValidator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

protocol PurchaseValidator {
    func validatePurchase(
        transaction: PurchasedTransaction,
        reason: Adapty.ValidatePurchaseReason,
        _: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>
    )
}

extension Adapty: PurchaseValidator {
    func syncTransactions(
        refreshReceiptIfEmpty: Bool,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>?>
    ) {
        guard #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *),
              let sk2TransactionManager = _sk2TransactionManager as? SK2TransactionManager else {
            sk1ReceiptManager.validateReceipt(refreshIfEmpty: refreshReceiptIfEmpty) { [weak self] result in
                completion(result.map {
                    self?.saveResponse(profile: $0)
                    return $0
                })
            }
            return
        }

        sk2TransactionManager.syncTransactions { [weak self] result in
            completion(result.do {
                self?.saveResponse(profile: $0)
            })
        }
    }

    enum ValidatePurchaseReason {
        case setVariation
        case observing
        case purchasing
    }

    func validatePurchase(
        transaction: PurchasedTransaction,
        reason: ValidatePurchaseReason,
        _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>
    ) {
        httpSession.performValidateTransactionRequest(
            profileId: profileStorage.profileId,
            purchasedTransaction: transaction,
            reason: reason
        ) { [weak self] result in
            completion(result.do {
                self?.saveResponse(profile: $0)
            })
        }
    }

    private func saveResponse(profile: VH<AdaptyProfile>?) {
        guard let profile else { return }
        if profileStorage.profileId == profile.value.profileId {
            profileStorage.setSyncedTransactions(true)
        }
        state.initialized?.saveResponse(profile)
    }
}
