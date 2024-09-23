//
//  Environment.swift
//  AdaptySDK
//
//  Created by Andrey Kyashkin on 19.12.2019.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

#if canImport(WebKit)
    import WebKit
#endif

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

        @MainActor
        static let version: String = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                ProcessInfo().operatingSystemVersionString
            #else
                UIDevice.current.systemVersion
            #endif
        }()

        @MainActor
        static let name: String = {
            #if os(macOS) || targetEnvironment(macCatalyst)
                "macOS"
            #else
                UIDevice.current.systemName
            #endif
        }()
    }

    enum Device {
        #if targetEnvironment(simulator)
            static let isSimulator = true
        #else
            static let isSimulator = false
        #endif

//        typealias DisplayResolution = (width: Int, height: Int)
//
//        @MainActor
//        static var displayResolution: DisplayResolution? = {
//            #if os(macOS)
//                NSScreen.main?.frame.size
//            #elseif targetEnvironment(macCatalyst)
//                Optional.some(UIScreen.main.bounds.size)
//            #elseif os(visionOS)
//                DisplayResolution?.none
//            #else
//                Optional.some(UIScreen.main.bounds.size)
//            #endif
//        }().map { (width: Int($0.width), height: Int($0.height)) }

        @MainActor
        static let webViewUserAgent: String? = {
            #if canImport(WebKit)
                WKWebView().value(forKey: "userAgent").flatMap { $0 as? String }
            #else
                nil
            #endif
        }()

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
    }
}
