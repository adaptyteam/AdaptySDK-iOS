//
//  Environment.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 19/12/2019.
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
        static let version: String? = { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }()
        static let build: String? = { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }()
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
                #else
                    return Optional.some(UIScreen.main.bounds.size)
                #endif
            }().map { (width: Int($0.width), height: Int($0.height)) }
        }

        static var storeCountry: String? {
            if #available(iOS 13.0, macOS 10.15, *) {
                return SKPaymentQueue.default().storefront?.countryCode
            } else {
                return nil
            }
        }

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
                return machineMirror.children.reduce("", { identifier, element in
                    guard let value = element.value as? Int8, value != 0 else { return identifier }
                    return identifier + String(UnicodeScalar(UInt8(value)))
                })
            #endif
        }()

        static let idfa: String? = {
            guard !Adapty.Configuration.idfaCollectionDisabled else { return nil }
            // Get and return IDFA
            if #available(iOS 9.0, macOS 10.14, *) {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return nil
            }
        }()

        static let idfv: String? = {
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
        }()

        #if targetEnvironment(simulator)
            static let isSimulator = true
        #else
            static let isSimulator = false
        #endif
    }

    #if os(iOS)
        static func searchAdsAttribution(completion: @escaping ([String: Any]?, Error?) -> Void) {
            guard #available(iOS 14.3, *) else {
                completion(nil, nil)
                return
            }

            let attributionToken: String
            do {
                attributionToken = try AAAttribution.attributionToken()
            } catch {
                completion(nil, error)
                return
            }

            let request = NSMutableURLRequest(url: URL(string: "https://api-adservices.apple.com/api/v1/")!)
            request.httpMethod = "POST"
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data(attributionToken.utf8)

            URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, _, error in
                guard let data = data else {
                    completion(nil, error)
                    return
                }

                let result: [String: Any]?
                do {
                    result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                } catch {
                    completion(nil, error)
                    return
                }

                guard var result = result else {
                    completion(nil, nil)
                    return
                }

                result["asa-attribution"] = true
                completion(result, nil)
            }).resume()
        }

    #endif
}

#if canImport(AppTrackingTransparency)
    import AppTrackingTransparency

    extension Environment.Device {
        @available(iOS 14, macOS 11.0, *)
        static var appTrackingTransparencyStatus: ATTrackingManager.AuthorizationStatus {
            ATTrackingManager.trackingAuthorizationStatus
        }
    }
#endif
