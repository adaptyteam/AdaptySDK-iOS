//
//  DefaultsManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/10/2019.
//  Copyright © 2019 4Taps. All rights reserved.
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
            let events = defaults.array(forKey: Constants.UserDefaults.cachedEvents) as? [[String: String]]
            return events ?? []
        }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaults.cachedEvents)
        }
    }
    
    func clean() {
        let appDomain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: appDomain)
    }
    
}
