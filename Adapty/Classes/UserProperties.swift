//
//  UserProperties.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import AdSupport
import Foundation
import UIKit
import iAd

class UserProperties {
    
    private(set) static var staticUuid = UUID().stringValue
    class func resetStaticUuid() {
        staticUuid = UUID().stringValue
    }
    
    static var uuid: String {
        return UUID().stringValue
    }
    
    static var idfa: String? {
        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    static var sdkVersion: String? {
        return Bundle(for: Self.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var sdkVersionBuild: Int {
        return Constants.Versions.SDKBuild
    }
    
    static var appBuild: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var device: String {
        return UIDevice.modelName
    }
    
    static var locale: String {
        return Locale.preferredLanguages.first ?? Locale.current.identifier
    }
    
    static var OS: String {
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
    
    static var platform: String {
        return UIDevice.current.systemName
    }
    
    static var timezone: String {
        return TimeZone.current.identifier
    }
    
    static var deviceIdentifier: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    class func appleSearchAdsAttribution(completion: @escaping (Parameters?, Error?) -> Void) {
        ADClient.shared().requestAttributionDetails(completion)
    }
    
}
