//
//  DefaultsManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

class DefaultsManager {
    
    static let shared = DefaultsManager()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    var profile: ProfileModel? {
        get {
            if let data = defaults.object(forKey: Constants.UserDefaults.profile) as? Data, let profile = try? JSONDecoder().decode(ProfileModel.self, from: data) {
                return profile
            }
            
            return nil
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: Constants.UserDefaults.profile)
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
    
    func clean() {
        defaults.removeObject(forKey: Constants.UserDefaults.cachedEvents)
        defaults.removeObject(forKey: Constants.UserDefaults.cachedTransactionsIds)
    }
    
}
