//
//  ApiKeyHash+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.10.2022.
//

import Foundation

private let log = Log.storage

extension UserDefaults {
    fileprivate enum Constants {
        static let appKeyHash = "AdaptySDK_Application_Key_Hash"
    }

    @discardableResult
    func clearAllDataIfDifferent(apiKey: String) async -> Bool {
        let hash = apiKey.sha256()

        guard let value = string(forKey: Constants.appKeyHash) else {
            set(hash, forKey: Constants.appKeyHash)
            return false
        }

        if value == hash { return false }

        log.verbose("changing apiKeyHash = \(hash).")
        clearProfile(newProfileId: nil)
        await EventsStorage.clearAll()
        clearProductVendorIds()
        clearVariationsIds()
        set(hash, forKey: Constants.appKeyHash)
        return true
    }
}
