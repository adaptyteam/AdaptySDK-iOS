//
//  Adapty+ReceiptValidator.swift
//  Adapty
//
//  Created by Aleksei Valiano on 24.10.2022.
//

import Foundation

extension Adapty: ReceiptValidator {
    func validateReceipt(purchaseProductInfo: PurchaseProductInfo? = nil, refreshIfEmpty: Bool, _ completion: @escaping ResultCompletion<Profile>) {
        skReceiptManager.getReceipt(refreshIfEmpty: refreshIfEmpty) { [weak self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(Receipt):

                guard let self = self else { return }

                let profileId = self.profileStorage.profileId

                self.httpSession.performValidateReceiptRequest(profileId: profileId,
                                                               receipt: Receipt,
                                                               purchaseProductInfo: purchaseProductInfo) { [weak self] result in

                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                    case let .success(profile):
                        if let storage = self?.profileStorage, storage.profileId == profile.value.profileId {
                            storage.setSyncedBundleReceipt()
                            // TODO: save profile
                        }
                        if let manager = self?.state.initilized, manager.isActive, manager.profileId == profile.value.profileId {
                            manager.saveResponse(profile)
                        }
                        completion(.success(profile.value))
                    }
                }
            }
        }
    }
}
