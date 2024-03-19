//
//  ApiKeyHash+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 17.10.2022.
//

import Foundation

extension UserDefaults {
    fileprivate enum Constants {
        static let appKeyHash = "AdaptySDK_Application_Key_Hash"
    }

    @discardableResult
    func clearAllDataIfDifferent(apiKey: String) -> Bool {
        let hash = apiKey.sha256()

        guard let value = string(forKey: Constants.appKeyHash) else {
            set(hash, forKey: Constants.appKeyHash)
            return false
        }

        if value == hash { return false }

        Log.verbose("UserDefaults: changing apiKeyHash = \(hash).")
        clearProfile(newProfileId: nil)
        clearEvents()
        clearProductVendorIds()
        clearVariationsIds()
        set(hash, forKey: Constants.appKeyHash)
        return true
    }
}
