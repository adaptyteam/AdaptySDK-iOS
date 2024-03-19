//
// Environment.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

#if canImport(AdSupport)
    import AdSupport
#endif

#if canImport(AdServices)
    import AdServices
#endif

import Foundation
#if canImport(UIKit)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

#if canImport(WebKit)
    import WebKit
#endif

import StoreKit

enum Environment {
    enum Application {
        static let version: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        static let build: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        static let sessionIdentifier = UUID().uuidString.lowercased()
    }

    enum User {
        static var locale: AdaptyLocale { AdaptyLocale(id: Locale.preferredLanguages.first ?? Locale.current.identifier) }
    }

    enum System {
        static var timezone: String { TimeZone.current.identifier }

        static let version: String = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                ProcessInfo().operatingSystemVersionString
            #else
                UIDevice.current.systemVersion
            #endif
        }()

        static let name: String = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                "macOS"
            #else
                UIDevice.current.systemName
            #endif
        }()

        static let isSandbox: Bool = {
            guard !Device.isSimulator else { return true }

            guard let path = Bundle.main.appStoreReceiptURL?.path else { return false }

            if path.contains("MASReceipt/receipt") {
                return path.contains("Xcode/DerivedData")
            } else {
                return path.contains("sandboxReceipt")
            }
        }()
    }

    enum Device {
        typealias DisplayResolution = (width: Int, height: Int)

        static var displayResolution: DisplayResolution? {
            {
                #if os(macOS)
                    return NSScreen.main?.frame.size
                #elseif targetEnvironment(macCatalyst)
                    return Optional.some(UIScreen.main.bounds.size)
                #elseif os(visionOS)
                    return DisplayResolution?.none
                #else
                    return Optional.some(UIScreen.main.bounds.size)
                #endif
            }().map { (width: Int($0.width), height: Int($0.height)) }
        }

        static var storeCountry: String? { SKStorefrontManager.countryCode }

        private static var _webViewUserAgent: String?
        static var webViewUserAgent: String? {
            if let value = _webViewUserAgent { return value }
            #if canImport(WebKit)
                DispatchQueue.syncInMainIfNeeded {
                    Device._webViewUserAgent = WKWebView().value(forKey: "userAgent").flatMap { $0 as? String }
                }
                return Device._webViewUserAgent
            #else
                return nil
            #endif
        }

        static var ipV4Address: String?

        static let name: String = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))

                var modelIdentifier: String?
                if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
                    modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
                }
                IOObjectRelease(service)

                if modelIdentifier?.isEmpty ?? false {
                    modelIdentifier = nil
                }

                return modelIdentifier ?? "unknown device"

            #else
                var systemInfo = utsname()
                uname(&systemInfo)
                let machineMirror = Mirror(reflecting: systemInfo.machine)
                return machineMirror.children.reduce("") { identifier, element in
                    guard let value = element.value as? Int8, value != 0 else { return identifier }
                    return identifier + String(UnicodeScalar(UInt8(value)))
                }
            #endif
        }()

        static let idfa: String? = {
            #if !canImport(AdSupport)
                return nil
            #else
                guard !Adapty.Configuration.idfaCollectionDisabled else { return nil }
                // Get and return IDFA
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            #endif
        }()

        static let idfv: String? = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                let matchingDict = IOServiceMatching("IOPlatformExpertDevice")
                let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, matchingDict)
                defer { IOObjectRelease(platformExpert) }

                guard platformExpert != 0 else { return nil }
                return IORegistryEntryCreateCFProperty(
                    platformExpert,
                    kIOPlatformUUIDKey as CFString,
                    kCFAllocatorDefault,
                    0
                ).takeRetainedValue() as? String
            #else
                return UIDevice.current.identifierForVendor?.uuidString
            #endif
        }()

        #if targetEnvironment(simulator)
            static let isSimulator = true
        #else
            static let isSimulator = false
        #endif
    }

    #if canImport(AdServices)
        @available(iOS 14.3, macOS 11.1, visionOS 1.0, *)
        static func getASAToken() throws -> String {
            let callId = Log.stamp
            let methodName = "fetch_ASA_Token"
            Adapty.logSystemEvent(AdaptyAppleRequestParameters(
                methodName: methodName,
                callId: callId
            ))

            let attributionToken: String
            do {
                attributionToken = try AAAttribution.attributionToken()

            } catch {
                Log.error("UpdateASAToken: On AAAttribution.attributionToken \(error)")
                Adapty.logSystemEvent(AdaptyAppleResponseParameters(
                    methodName: methodName,
                    callId: callId,
                    error: "\(error.localizedDescription). Detail: \(error)"
                ))
                throw error
            }

            Adapty.logSystemEvent(AdaptyAppleResponseParameters(
                methodName: methodName,
                callId: callId,
                params: [
                    "token": .value(attributionToken),
                ]
            ))

            return attributionToken
        }
    #endif
}

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency

    extension Environment.Device {
        @available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, *)
        static var appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus {
            ATTrackingManager.trackingAuthorizationStatus
        }
    }
#endif
