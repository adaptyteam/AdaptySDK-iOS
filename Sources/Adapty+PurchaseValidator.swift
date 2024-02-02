//
//  Adapty+PurchaseValidator.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

protocol PurchaseValidator {
    func validatePurchase(transaction: PurchasedTransaction,
                          _: @escaping AdaptyResultCompletion<AdaptyProfile>)
}

extension Adapty: PurchaseValidator {
    func validateReceipt(refreshIfEmpty: Bool,
                         _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        skReceiptManager.validateReceipt(
            refreshIfEmpty: refreshIfEmpty
        ) { [weak self] result in
            completion(result.map { profile in
                self?.saveValidateResponse(profile: profile)
                return profile
            })
        }
    }

    func validatePurchase(transaction: PurchasedTransaction,
                          _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        httpSession.performValidateTransactionRequest(
            profileId: profileStorage.profileId,
            purchasedTransaction: transaction
        ) { [weak self] result in
            completion(result.map { profile in
                self?.saveValidateResponse(profile: profile)
                return profile.value
            })
        }
    }

    private func saveValidateResponse(profile: VH<AdaptyProfile>) {
        if profileStorage.profileId == profile.value.profileId {
            profileStorage.setSyncedBundleReceipt(true)
        }
        if let manager = state.initialized {
            manager.saveResponse(profile)
        }
    }
}
