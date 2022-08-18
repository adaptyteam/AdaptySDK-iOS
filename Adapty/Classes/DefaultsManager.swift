//
//  DefaultsManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

@objc public enum DataState: Int, Codable {
    case cached
    case synced
}

class DefaultsManager {
    
    enum Constants {
        static let profileId = "AdaptySDK_Profile_Id"
        static let installation = "AdaptySDK_Installation"
        static let cachedEvents = "AdaptySDK_Cached_Events"
        static let cachedVariationsIds = "AdaptySDK_Cached_Variations_Ids"
        static let purchaserInfo = "AdaptySDK_Purchaser_Info"
        static let cachedPaywalls = "AdaptySDK_Cached_Purchase_Containers"
        static let cachedProducts = "AdaptySDK_Cached_Products"
        static let appleSearchAdsSyncDate = "AdaptySDK_Apple_Search_Ads_Sync_Date"
        static let externalAnalyticsDisabled = "AdaptySDK_External_Analytics_Disabled"
        static let previousResponseHashes = "AdaptySDK_Previous_Response_Hashes"
        static let responseJSONCaches = "AdaptySDK_Response_JSON_Caches"
        static let postRequestParamsHashes = "AdaptySDK_Post_Request_Params_Hashes"
    }
    
    static let shared = DefaultsManager()
    private var defaults = UserDefaults.standard

    private init() {}
    init(with defaults: UserDefaults) {
        self.defaults = defaults
    }

    var profileId: String {
        get {
            if let profileId = defaults.string(forKey: Constants.profileId) {
                return profileId
            }

            // try to restore profileId from cached profile
            // basically, backward compatibility only
            if let profileId = purchaserInfo?.profileId {
                self.profileId = profileId
                return profileId
            }

            // generate new profileId
            let profileId = UserProperties.uuid
            self.profileId = profileId
            return profileId
        }
        set {
            defaults.set(newValue, forKey: Constants.profileId)
        }
    }

    var purchaserInfo: PurchaserInfoModel? {
        get {
            if let data = defaults.object(forKey: Constants.purchaserInfo) as? Data, let purchaserInfo = try? JSONDecoder().decode(PurchaserInfoModel.self, from: data) {
                return purchaserInfo
            }

            return nil
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.purchaserInfo)
        }
    }

    var installation: InstallationModel? {
        get {
            if let data = defaults.object(forKey: Constants.installation) as? Data, let installation = try? JSONDecoder().decode(InstallationModel.self, from: data) {
                return installation
            }

            return nil
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.installation)
        }
    }

    var cachedEvents: [[String: String]] {
        get {
            return defaults.array(forKey: Constants.cachedEvents) as? [[String: String]] ?? []
        }
        set {
            defaults.set(newValue, forKey: Constants.cachedEvents)
        }
    }

    var cachedVariationsIds: [String: String] {
        get {
            return defaults.dictionary(forKey: Constants.cachedVariationsIds) as? [String: String] ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Constants.cachedVariationsIds)
        }
    }

    var cachedPaywalls: [String: PaywallModel] {
        get {
            if
                let data = defaults.object(forKey: Constants.cachedPaywalls) as? Data,
                let array = try? JSONDecoder().decode([PaywallModel].self, from: data) {
                let paywalls = Dictionary( array.map { ( $0.developerId, $0) } ,  uniquingKeysWith: { (_, last) in last })
                return paywalls
            }
            
            return [:]
        }
        set {
            let array = Array(newValue.values)
            let data = try? JSONEncoder().encode(array)
            defaults.set(data, forKey: Constants.cachedPaywalls)
        }
    }
    
    var cachedProducts: [ProductModel] {
        get {
            if let data = defaults.object(forKey: Constants.cachedProducts) as? Data, let products = try? JSONDecoder().decode([ProductModel].self, from: data) {
                return products
            }

            return []
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.cachedProducts)
        }
    }

    var appleSearchAdsSyncDate: Date? {
        get {
            return defaults.object(forKey: Constants.appleSearchAdsSyncDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Constants.appleSearchAdsSyncDate)
        }
    }

    var externalAnalyticsDisabled: Bool {
        get {
            return defaults.bool(forKey: Constants.externalAnalyticsDisabled)
        }
        set {
            defaults.set(newValue, forKey: Constants.externalAnalyticsDisabled)
        }
    }

    // [%requestType: %hash]
    var previousResponseHashes: [String: String] {
        get {
            return (defaults.dictionary(forKey: Constants.previousResponseHashes) as? [String: String]) ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Constants.previousResponseHashes)
        }
    }

    // [%requestType: [%hash: data]]
    var responseJSONCaches: [String: [String: Data]] {
        get {
            return (defaults.dictionary(forKey: Constants.responseJSONCaches) as? [String: [String: Data]]) ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Constants.responseJSONCaches)
        }
    }

    var postRequestParamsHashes: [String: String] {
        get {
            return (defaults.dictionary(forKey: Constants.postRequestParamsHashes) as? [String: String]) ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Constants.postRequestParamsHashes)
        }
    }

    func clean() {
        defaults.removeObject(forKey: Constants.cachedEvents)
        defaults.removeObject(forKey: Constants.cachedVariationsIds)
        defaults.removeObject(forKey: Constants.cachedPaywalls)
        defaults.removeObject(forKey: Constants.cachedProducts)
        defaults.removeObject(forKey: Constants.appleSearchAdsSyncDate)
        defaults.removeObject(forKey: Constants.externalAnalyticsDisabled)
        defaults.removeObject(forKey: Constants.previousResponseHashes)
        defaults.removeObject(forKey: Constants.responseJSONCaches)
        defaults.removeObject(forKey: Constants.postRequestParamsHashes)
    }
}
