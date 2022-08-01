//
//  UserService.swift
//  Adapty-Demo
//
//  Created by Elena Gordienko on 01.08.22.
//  Copyright © 2022 Adapty. All rights reserved.
//

import Adapty
import Foundation
import SwiftUI

final class UserService: ObservableObject {
    @Published private(set) var user: User? {
        didSet {
            isPremium = user?.isPremium ?? false
        }
    }
    @Published var isPremium: Bool = false
    
    var isLoggedIn: Bool { user != nil }
    
    // MARK: - Login
    
    func login(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            let userID = "user_id"
            self?.user = User(id: userID, name: "Buddy", isPremium: false)
            Adapty.identify(userID) { [weak self] error in
                if let error = error {
                    print(error.debugDescription)
                } else {
                    self?.getPurchaserInfo()
                }
            }
            completion()
        }
    }
    
    // MARK: - Logout
    
    func logout(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            Adapty.logout { (error) in
                if let error = error {
                    print(error.debugDescription)
                }
            }
            self?.user = nil
            completion()
        }
    }
    
    // MARK: - Get Purchaser Info
    
    func getPurchaserInfo(completion: ((Bool, Error?) -> Void)? = nil) {
        Adapty.getPurchaserInfo(forceUpdate: true) { [weak self] purchaserInfo, error in
            switch (purchaserInfo, error) {
            case (.some(let info), nil):
                self?.updatePremiumStatus(with: info, error: nil, completion: completion)
            case (_, let error):
                print(error.debugDescription)
                completion?(false, error)
            }
        }
    }
    
    // MARK: - Make Purchase
    
    func makePurchase(for product: ProductModel, completion: @escaping ((Bool, Error?) -> Void)) {
        Adapty.makePurchase(product: product) { [weak self] purchaserInfo, receipt, validationResult, product, error in
            guard let purchaserInfo = purchaserInfo else {
                completion(false, error)
                return
            }
            self?.updatePremiumStatus(with: purchaserInfo, error: error)
        }
    }
    
    // MARK: - Update Premium Status
    
    private func updatePremiumStatus(
        with paymentInfo: PurchaserInfoModel,
        error: Error? = nil,
        completion: ((Bool, Error?) -> Void)? = nil
    ) {
        let isPremium = paymentInfo.accessLevels["premium"]?.isActive ?? false
        user?.updateIsPremium(isPremium)
        completion?(isPremium, error)
    }
}

// MARK: - AdaptyDelegate

extension UserService: AdaptyDelegate {
    
    func didReceivePromo(_ promo: PromoModel) { }
    
    func didReceiveUpdatedPurchaserInfo(_ purchaserInfo: PurchaserInfoModel) {
        updatePremiumStatus(with: purchaserInfo)
    }
}
