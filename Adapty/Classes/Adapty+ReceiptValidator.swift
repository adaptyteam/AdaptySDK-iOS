//
//  Adapty+ReceiptValidator.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

extension Adapty: ReceiptValidator {
    func validateReceipt(refreshIfEmpty: Bool, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        skReceiptManager.validateReceipt(refreshIfEmpty: refreshIfEmpty) { [weak self] result in
            completion(result.map { profile in
                self?.saveValidateRecieptResponse(profile: profile)
                return profile
            })
        }
    }

    fileprivate func saveValidateRecieptResponse(profile: VH<AdaptyProfile>) {
        if profileStorage.profileId == profile.value.profileId {
            profileStorage.setSyncedBundleReceipt()
        }
        if let manager = state.initilized {
            manager.saveResponse(profile)
        }
    }

    func validateReceipt(purchaseProductInfo: PurchaseProductInfo, _ completion: @escaping AdaptyResultCompletion<VH<AdaptyProfile>>) {
        skReceiptManager.getReceipt(refreshIfEmpty: true) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(receipt):
                guard let self = self else { return }
                let profileId = self.profileStorage.profileId
                self.httpSession.performValidateReceiptRequest(profileId: profileId,
                                                               receipt: receipt,
                                                               purchaseProductInfo: purchaseProductInfo) { [weak self] result in
                    completion(result.map { profile in
                        self?.saveValidateRecieptResponse(profile: profile)
                        return profile
                    })
                }
            }
        }
    }
}
