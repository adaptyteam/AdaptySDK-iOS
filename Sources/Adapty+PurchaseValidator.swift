//
//  Adapty+PurchaseValidator.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

protocol PurchaseValidator {
    func validatePurchase(info: PurchaseProductInfo, _: @escaping AdaptyResultCompletion<AdaptyProfile>)
}

extension Adapty: PurchaseValidator {
    func validateReceipt(refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        skReceiptManager.validateReceipt(refreshIfEmpty: refreshIfEmpty) { [weak self] result in
            completion(result.map { profile in
                self?.saveValidateReceiptResponse(profile: profile)
                return profile
            })
        }
    }

    fileprivate func saveValidateReceiptResponse(profile: VH<AdaptyProfile>) {
        if profileStorage.profileId == profile.value.profileId {
            profileStorage.setSyncedBundleReceipt(true)
        }
        if let manager = state.initialized {
            manager.saveResponse(profile)
        }
    }

    func validatePurchase(info: PurchaseProductInfo, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        guard info.originalTransactionId != nil, Environment.StoreKit2.available else {
            validatePurchaseByReceipt(info: info, completion)
            return
        }

        httpSession.performValidateTransactionRequest(profileId: profileStorage.profileId,
                                                      purchaseProductInfo: info) { [weak self] result in
            completion(result.map { profile in
                self?.saveValidateReceiptResponse(profile: profile)
                return profile.value
            })
        }
    }

    fileprivate func validatePurchaseByReceipt(info: PurchaseProductInfo, _ completion: @escaping AdaptyResultCompletion<AdaptyProfile>) {
        skReceiptManager.getReceipt(refreshIfEmpty: true) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(receipt):
                guard let self = self else { return }
                let profileId = self.profileStorage.profileId
                self.httpSession.performValidateTransactionRequest(profileId: profileId,
                                                                   purchaseProductInfo: info,
                                                                   withReceipt: receipt) { [weak self] result in
                    completion(result.map { profile in
                        self?.saveValidateReceiptResponse(profile: profile)
                        return profile.value
                    })
                }
            }
        }
    }
}
