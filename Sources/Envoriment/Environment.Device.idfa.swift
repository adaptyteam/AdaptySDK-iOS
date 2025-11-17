//
//  Environment.Device.idfa.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

import Foundation

#if !ADAPTY_KIDS_MODE && canImport(AdSupport)
import AdSupport
#endif

#if !ADAPTY_KIDS_MODE && canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

private let log = Log.default

extension AdaptyConfiguration {
    @AdaptyActor
    static var idfaCollectionDisabled = Self.default.idfaCollectionDisabled
}

extension Environment.Device {
    enum IdfaRetrievalStatus: Sendable {
        case notAvailable
        case notDetermined
        case denied
        case allowed
    }

    static var appTrackingTransparencyStatus: UInt? {
        #if ADAPTY_KIDS_MODE || !canImport(AppTrackingTransparency)
        nil
        #else
        ATTrackingManager.trackingAuthorizationStatus.rawValue
        #endif
    }

    @AdaptyActor
    static var idfaRetrievalStatus: IdfaRetrievalStatus {
        get async {
            #if ADAPTY_KIDS_MODE || !canImport(AdSupport) || targetEnvironment(simulator) || os(macOS)
            return .notAvailable
            #else
            guard !AdaptyConfiguration.idfaCollectionDisabled else {
                return .notAvailable
            }

            #if !canImport(AppTrackingTransparency)
            return .notAvailable
            #else
            return await ATTrackingManager.canTakeIdfa
            #endif
            #endif
        }
    }

    @AdaptyActor
    private static var _idfa: String?

    @AdaptyActor
    static var idfa: String? {
        get async {
            #if ADAPTY_KIDS_MODE || !canImport(AdSupport) || targetEnvironment(simulator) || os(macOS)
            return nil
            #else

            guard !AdaptyConfiguration.idfaCollectionDisabled else { return nil }

            if let result = _idfa { return result }

            // Get and return IDFA

            let result: String? = await MainActor.run {
                #if canImport(AppTrackingTransparency)
                return switch ATTrackingManager.trackingAuthorizationStatus {
                case .authorized:
                    ASIdentifierManager.shared().advertisingIdentifier.uuidString
                default:
                    nil
                }
                #else
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
                #endif
            }

            if let result {
                _idfa = result
            }
            return result

            #endif
        }
    }
}

#if !ADAPTY_KIDS_MODE && canImport(AppTrackingTransparency)
private extension ATTrackingManager {
    @MainActor
    static var canTakeIdfa: Environment.Device.IdfaRetrievalStatus {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .notDetermined: return .notDetermined
        case .restricted, .denied: return .denied
        case .authorized: return .allowed
        @unknown default: return .notDetermined
        }
    }
}
#endif
