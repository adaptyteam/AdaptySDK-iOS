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

import Foundation

private let log = Log.default

extension Adapty.Configuration {
    @AdaptyActor
    static var idfaCollectionDisabled = Self.default.idfaCollectionDisabled
}

extension Environment.Device {
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, *)
    static var appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }

    enum IdfaRetriavalStatus: Sendable {
        case notAvailable

        case notDetermined

        case denied
        case allowed
    }

    @AdaptyActor
    static var idfaRetriavalStatus: IdfaRetriavalStatus {
        get async {
            #if !canImport(AdSupport) || targetEnvironment(simulator) || os(macOS)
                return .notAvailable
            #else
                guard !Adapty.Configuration.idfaCollectionDisabled else {
                    return .notAvailable
                }

                guard #available(iOS 14.5, macOS 11.0, tvOS 14.0, visionOS 1.0, *) else {
                    return .allowed
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
            #if !canImport(AdSupport) || targetEnvironment(simulator) || os(macOS)
                return nil
            #else

                guard !Adapty.Configuration.idfaCollectionDisabled else { return nil }

                if let result = _idfa { return result }

                // Get and return IDFA

                let result: String? = await MainActor.run {
                    guard #available(iOS 14.5, macOS 11.0, tvOS 14.0, visionOS 1.0, *) else {
                        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    }

                    #if canImport(AppTrackingTransparency)
                        return switch ATTrackingManager.trackingAuthorizationStatus {
                        case .authorized:
                            ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        default:
                            String?.none
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

#if canImport(AppTrackingTransparency)
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, *)
    private extension ATTrackingManager {
        @MainActor
        static var canTakeIdfa: Environment.Device.IdfaRetriavalStatus {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined: return .notDetermined
            case .restricted, .denied: return .denied
            case .authorized: return .allowed
            @unknown default: return .notDetermined
            }
        }
    }
#endif
