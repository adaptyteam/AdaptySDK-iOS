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
        Adapty.getProfile { [weak self] result in
            switch result {
            case let .success(profile):
                self?.updatePremiumStatus(with: profile, error: nil, completion: completion)
            case let .failure(error):
                print(error.debugDescription)
                completion?(false, error)
            }
        }
    }

    // MARK: - Make Purchase

    func makePurchase(for product: AdaptyPaywallProduct, completion: @escaping ((Bool, Error?) -> Void)) {
        Adapty.makePurchase(product: product) { [weak self] result in
            switch result {
            case let .success(profile):
                self?.updatePremiumStatus(with: profile, error: nil, completion: completion)
            case let .failure(error):
                completion(false, error)
            }
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases(completion: @escaping ((Bool, Error?) -> Void)) {
        Adapty.restorePurchases { [weak self] result in
            switch result {
            case let .success(profile):
                self?.updatePremiumStatus(with: profile, completion: completion)
            case let .failure(error):
                completion(self?.isPremium ?? false, error)
            }
        }
    }

    // MARK: - Update Premium Status

    private func updatePremiumStatus(
        with profile: AdaptyProfile,
        error: Error? = nil,
        completion: ((Bool, Error?) -> Void)? = nil
    ) {
        let isPremium = profile.accessLevels["premium"]?.isActive ?? false
        user?.updateIsPremium(isPremium)
        completion?(isPremium, error)
    }
}

// MARK: - AdaptyDelegate

extension UserService: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        updatePremiumStatus(with: profile)
    }
}
