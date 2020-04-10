//
//  DefaultsManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

@objc public enum DataState: Int {
    case cached
    case synced
}

class DefaultsManager {
    
    static let shared = DefaultsManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    var profileId: String {
        get {
            if let profileId = defaults.string(forKey: Constants.UserDefaults.profileId) {
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
            defaults.set(newValue, forKey: Constants.UserDefaults.profileId)
        }
    }
    
    var purchaserInfo: PurchaserInfoModel? {
        get {
            if let data = defaults.object(forKey: Constants.UserDefaults.purchaserInfo) as? Data, let purchaserInfo = try? JSONDecoder().decode(PurchaserInfoModel.self, from: data) {
                return purchaserInfo
            }
            
            return nil
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.UserDefaults.purchaserInfo)
        }
    }
    
    var installation: InstallationModel? {
        get {
            if let data = defaults.object(forKey: Constants.UserDefaults.installation) as? Data, let installation = try? JSONDecoder().decode(InstallationModel.self, from: data) {
                return installation
            }
            
            return nil
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.UserDefaults.installation)
        }
    }

    var cachedEvents: [[String: String]] {
        get {
            return defaults.array(forKey: Constants.UserDefaults.cachedEvents) as? [[String: String]] ?? []
        }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaults.cachedEvents)
        }
    }
    
    var cachedTransactionsIds: [String: String] {
        get {
            return defaults.dictionary(forKey: Constants.UserDefaults.cachedTransactionsIds) as? [String: String] ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaults.cachedTransactionsIds)
        }
    }
    
    var cachedPurchaseContainers: [PurchaseContainerModel]? {
        get {
            if let data = defaults.object(forKey: Constants.UserDefaults.cachedPurchaseContainers) as? Data, let containers = try? JSONDecoder().decode([PurchaseContainerModel].self, from: data) {
                return containers
            }
            
            return nil
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.UserDefaults.cachedPurchaseContainers)
        }
    }
    
    var cachedProducts: [ProductModel]? {
        get {
            if let data = defaults.object(forKey: Constants.UserDefaults.cachedProducts) as? Data, let products = try? JSONDecoder().decode([ProductModel].self, from: data) {
                return products
            }
            
            return nil
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.UserDefaults.cachedProducts)
        }
    }
    
    func clean() {
        defaults.removeObject(forKey: Constants.UserDefaults.cachedEvents)
        defaults.removeObject(forKey: Constants.UserDefaults.cachedTransactionsIds)
        defaults.removeObject(forKey: Constants.UserDefaults.cachedPurchaseContainers)
        defaults.removeObject(forKey: Constants.UserDefaults.cachedProducts)
    }
    
}
