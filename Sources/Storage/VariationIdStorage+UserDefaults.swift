//
//  VariationIdStorage+UserDefaults.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 07.10.2022.
//

import Foundation

extension UserDefaults: VariationIdStorage {
    fileprivate enum Constants {
        static let variationsIds = "AdaptySDK_Cached_Variations_Ids"
        static let persistentVariationsIds = "AdaptySDK_Variations_Ids"
    }

    func getVariationsIds() -> [String: String]? {
        dictionary(forKey: Constants.variationsIds) as? [String: String]
    }

    func setVariationsIds(_ value: [String: String]) {
        Log.debug("UserDefaults: Saving variationsIds for purchased product")
        set(value, forKey: Constants.variationsIds)
    }

    func getPersistentVariationsIds() -> [String: String]? {
        dictionary(forKey: Constants.persistentVariationsIds) as? [String: String]
    }

    func setPersistentVariationsIds(_ value: [String: String]) {
        set(value, forKey: Constants.persistentVariationsIds)
    }

    func clearVariationsIds() {
        Log.debug("UserDefaults: Clear variationsIds for purchased product.")
        removeObject(forKey: Constants.variationsIds)
        removeObject(forKey: Constants.persistentVariationsIds)
    }
}
