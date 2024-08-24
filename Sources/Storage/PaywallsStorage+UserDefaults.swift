//
//  PaywallsStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

private let log = Log.storage

extension UserDefaults: PaywallsStorage {
    fileprivate enum Constants {
        static let paywallsStorageKey = "AdaptySDK_Cached_Purchase_Containers"
        static let paywallsStorageVersionKey = "AdaptySDK_Cached_Purchase_Containers_Version"
        static let currentPaywallsStorageVersion = 2
    }

    func setPaywalls(_ paywalls: [VH<AdaptyPaywall>]) {
        guard !paywalls.isEmpty else {
            log.debug("Clear paywalls.")
            removeObject(forKey: Constants.paywallsStorageKey)
            return
        }
        do {
            set(Constants.currentPaywallsStorageVersion, forKey: Constants.paywallsStorageVersionKey)
            try setJSON(paywalls, forKey: Constants.paywallsStorageKey)
            log.debug("Saving paywalls success.")

        } catch {
            log.error("Saving paywalls fail. \(error.localizedDescription)")
        }
    }

    func getPaywalls() -> [VH<AdaptyPaywall>]? {
        guard integer(forKey: Constants.paywallsStorageVersionKey) == Constants.currentPaywallsStorageVersion else {
            return nil
        }
        do {
            return try getJSON([VH<AdaptyPaywall>].self, forKey: Constants.paywallsStorageKey)
        } catch {
            log.error(error.localizedDescription)
            return nil
        }
    }

    func clearPaywalls() {
        log.debug("Clear paywalls.")
        removeObject(forKey: Constants.paywallsStorageKey)
    }
}
