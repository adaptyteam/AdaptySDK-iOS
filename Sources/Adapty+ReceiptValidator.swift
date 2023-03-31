//
//  Adapty+ReceiptValidator.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

protocol PurchaseValidator {
    func validatePurchase(info: PurchaseProductInfo, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>)
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
            profileStorage.setSyncedBundleReceipt()
        }
        if let manager = state.initialized {
            manager.saveResponse(profile)
        }
    }

    func validatePurchase(info: PurchaseProductInfo, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        skReceiptManager.getReceipt(refreshIfEmpty: true) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(receipt):
                guard let self = self else { return }
                let profileId = self.profileStorage.profileId
                self.httpSession.performValidateReceiptRequest(profileId: profileId,
                                                               receipt: receipt,
                                                               purchaseProductInfo: info) { [weak self] result in
                    completion(result.map { profile in
                        self?.saveValidateReceiptResponse(profile: profile)
                        return profile
                    })
                }
            }
        }
    }
}
