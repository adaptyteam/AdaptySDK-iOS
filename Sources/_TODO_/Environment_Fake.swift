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

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency
#endif

import StoreKit

private let log = Log.default

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

        static var version: String { "" }

        static var name: String { "" }

        static let isSandbox: Bool = {
            guard !Device.isSimulator else { return true }

            guard let path = Bundle.main.appStoreReceiptURL?.path else { return false }

            if path.contains("MASReceipt/receipt") {
                return path.contains("Xcode/DerivedData")
            } else {
                return path.contains("sandboxReceipt")
            }
        }()

        static var storeKit2Enabled: Bool {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                true
            } else {
                false
            }
        }
    }

    enum Device {
        typealias DisplayResolution = (width: Int, height: Int)

        static var displayResolution: DisplayResolution? { nil }

        static var storeCountry: String? { nil }

        static var webViewUserAgent: String? { nil }

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

        static var idfa: String? { nil }

        static var canTakeIdfa: Bool { false }

        static var idfv: String? { nil }

        #if targetEnvironment(simulator)
            static let isSimulator = true
        #else
            static let isSimulator = false
        #endif
    }

    #if canImport(AdServices)
        @available(iOS 14.3, macOS 11.1, visionOS 1.0, *)
        static func getASAToken() throws -> String { "" }
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
