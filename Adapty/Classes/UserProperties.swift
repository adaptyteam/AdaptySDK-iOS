//
//  UserProperties.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import Foundation
import AdSupport

class UserProperties {
    
    static let staticUuid = UUID().stringValue
    
    static var uuid: String {
        return UUID().stringValue
    }
    
    static var idfa: String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }
        
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
        #if os(iOS)
        return UIDevice.modelName
        #elseif os(macOS)
        return "TODO: implement"
        #endif
    }
    
    static var locale: String {
        return Locale.current.identifier
    }
    
    static var OS: String {
        #if os(iOS)
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #elseif os(macOS)
        return "TODO: implement"
        #endif
    }
    
    static var platform: String {
        #if os(iOS)
        return UIDevice.current.systemName
        #elseif os(macOS)
        return "TODO: implement"
        #endif
    }
    
    static var timezone: String {
        return TimeZone.current.identifier
    }
    
    static var deviceIdentifier: String? {
        #if os(iOS)
        return UIDevice.current.identifierForVendor?.uuidString
        #elseif os(macOS)
        return "TODO: implement"
        #endif
    }
    
}
