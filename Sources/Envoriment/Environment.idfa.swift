//
//  Environment.idfa.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

#if canImport(AdSupport)
    import AdSupport
#endif

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency
#endif

import StoreKit

private let log = Log.default

extension Environment.Device {
    private static var currentIdfa: String?

    static var idfa: String? {
        #if !canImport(AdSupport) || targetEnvironment(simulator) || os(macOS)
            return nil
        #else
            guard !Adapty.Configuration.idfaCollectionDisabled else { return nil }

            if let currentIdfa { return currentIdfa }

            // Get and return IDFA

            guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, *) else {
                currentIdfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                return currentIdfa
            }

            #if canImport(AppTrackingTransparency)
                switch ATTrackingManager.trackingAuthorizationStatus {
                case .authorized, .restricted, .denied:
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier
                    currentIdfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                default:
                    currentIdfa = nil
                }
            #else
                currentIdfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            #endif

            return currentIdfa

        #endif
    }

    static var canTakeIdfa: Bool {
        #if !canImport(AdSupport) || targetEnvironment(simulator) || os(macOS)
            return false
        #else
            if Adapty.Configuration.idfaCollectionDisabled {
                return false
            }

            guard #available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, *) else {
                return true
            }

            #if canImport(AppTrackingTransparency)
                switch ATTrackingManager.trackingAuthorizationStatus {
                case .restricted, .denied:
                    return false
                default:
                    return true
                }
            #else
                return true
            #endif
        #endif
    }
}
