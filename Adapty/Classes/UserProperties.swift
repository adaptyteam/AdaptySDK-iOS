//
//  UserProperties.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
//

import AdSupport
import Foundation
#if canImport(UIKit)
import UIKit
import iAd
#elseif os(macOS)
import AppKit
#endif

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
        if #available(iOS 9.0, macOS 10.14, *) {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return nil
        }
    }
    
    static var sdkVersion: String? {
        return Constants.Versions.SDKVersion
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
        #if os(macOS) || targetEnvironment(macCatalyst)
        let matchingDict = IOServiceMatching("IOPlatformExpertDevice")
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, matchingDict)
        defer { IOObjectRelease(service) }
        
        if let modelData = IORegistryEntryCreateCFProperty(service,
                                                           "model" as CFString,
                                                           kCFAllocatorDefault, 0).takeRetainedValue() as? Data,
           let cString = modelData.withUnsafeBytes({ $0.baseAddress?.assumingMemoryBound(to: UInt8.self) }) {
            return String(cString: cString)
        } else {
            return "unknown device"
        }
        #else
        return UIDevice.modelName
        #endif
    }
    
    static var locale: String {
        return Locale.preferredLanguages.first ?? Locale.current.identifier
    }
    
    static var OS: String {
        #if os(macOS) || targetEnvironment(macCatalyst)
        return "macOS \(ProcessInfo().operatingSystemVersionString)"
        #else
        return "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #endif
    }
    
    static var platform: String {
        #if os(macOS) || targetEnvironment(macCatalyst)
        return "macOS"
        #else
        return UIDevice.current.systemName
        #endif
    }
    
    static var timezone: String {
        return TimeZone.current.identifier
    }
    
    static var deviceIdentifier: String? {
        #if os(macOS) || targetEnvironment(macCatalyst)
        let matchingDict = IOServiceMatching("IOPlatformExpertDevice")
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, matchingDict)
        defer { IOObjectRelease(platformExpert) }
        
        guard platformExpert != 0 else { return nil }
        return IORegistryEntryCreateCFProperty(platformExpert,
                                               kIOPlatformUUIDKey as CFString,
                                               kCFAllocatorDefault, 0).takeRetainedValue() as? String
        #else
        return UIDevice.current.identifierForVendor?.uuidString
        #endif
    }
    
    #if os(iOS)
    class func appleSearchAdsAttribution(completion: @escaping (Parameters?, Error?) -> Void) {
        ADClient.shared().requestAttributionDetails(completion)
    }
    #endif
}
