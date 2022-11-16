//
//  ApiKeyHash+UserDefaults.swift
//  Adapty
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
        
        if let value = string(forKey: Constants.appKeyHash), value == hash {
            return false
        }
        
        Log.debug("UserDefaults: changing apiKeyHash = \(hash).")
        clearProfile(newProfileId: nil)
        clearEvents()
        clearProductVendorIds()
        clearVariationsIds()
        set(hash, forKey: Constants.appKeyHash)
        return true
    }
}
