//
//  SKStoreFrontManager.swift
//
//
//  Created by Aleksey Goncharov on 30.1.24..
//

import Foundation
import StoreKit

class SKStorefrontManager {
    static var countryCode: String? {
        if #available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.2, visionOS 1.0, *) {
            SKPaymentQueue.default().storefront?.countryCode
        } else {
            nil
        }
    }

    static func subscribeForUpdates(_ callback: @escaping (String) -> Void) {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            subscribeSK2ForUpdates(callback)
            return
        }
        #if !os(visionOS)
            if #available(iOS 11.0, macOS 11.0, tvOS 11.0, watchOS 7.0, *) {
                subscribeSK1ForUpdates(callback)
                return
            }
        #endif
    }

    #if !os(visionOS)
        @available(iOS 11.0, macOS 11.0, tvOS 11.0, watchOS 7.0, *)
        static func subscribeSK1ForUpdates(_ callback: @escaping (String) -> Void) {
            NotificationCenter.default.addObserver(
                forName: Notification.Name.SKStorefrontCountryCodeDidChange,
                object: nil,
                queue: nil
            ) { _ in
                guard let countryCode = Self.countryCode else {
                    Log.warn("SKStorefrontManager (SK1): SKStorefrontCountryCodeDidChange to nil")
                    return
                }

                Log.verbose("SKStorefrontManager (SK1): SKStorefrontCountryCodeDidChange new value: \(countryCode)")

                callback(countryCode)
            }
        }
    #endif

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
    static func subscribeSK2ForUpdates(_ callback: @escaping (String) -> Void) {
        Task(priority: .utility) {
            for await value in Storefront.updates {
                let countryCode = value.countryCode

                Log.verbose("SKStorefrontManager (SK2): Storefront.updates new value: \(countryCode)")

                callback(countryCode)
            }
        }
    }
}
