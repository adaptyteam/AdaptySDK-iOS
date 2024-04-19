//
//  PaywallsStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension UserDefaults: PaywallsStorage {
    fileprivate enum Constants {
        static let paywallsStorageKey = "AdaptySDK_Cached_Purchase_Containers"
        static let paywallsStorageVersionKey = "AdaptySDK_Cached_Purchase_Containers_Version"
        static let currentPaywallsStorageVersion = 2
    }

    func setPaywalls(_ paywalls: [VH<AdaptyPaywall>]) {
        guard !paywalls.isEmpty else {
            Log.debug("UserDefaults: Clear paywalls.")
            removeObject(forKey: Constants.paywallsStorageKey)
            return
        }
        do {
            set(Constants.currentPaywallsStorageVersion, forKey: Constants.paywallsStorageVersionKey)
            try setJSON(paywalls, forKey: Constants.paywallsStorageKey)
            Log.debug("UserDefaults: Saving paywalls success.")

        } catch {
            Log.error("UserDefaults: Saving paywalls fail. \(error.localizedDescription)")
        }
    }

    func getPaywalls() -> [VH<AdaptyPaywall>]? {
        guard integer(forKey: Constants.paywallsStorageVersionKey) == Constants.currentPaywallsStorageVersion else {
            return nil
        }
        do {
            return try getJSON([VH<AdaptyPaywall>].self, forKey: Constants.paywallsStorageKey)
        } catch {
            Log.error(error.localizedDescription)
            return nil
        }
    }

    func clearPaywalls() {
        Log.debug("UserDefaults: Clear paywalls.")
        removeObject(forKey: Constants.paywallsStorageKey)
    }
}
