//
//  SKStoreFrontManager.swift
//
//
//  Created by Aleksey Goncharov on 30.1.24..
//

import Foundation
import StoreKit

@available(iOS 13.0, *)
class SKStorefrontManager {
    static var countryCode: String? { SKPaymentQueue.default().storefront?.countryCode }

    static func subscribeForUpdates(_ callback: @escaping (String) -> Void) {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            subscribeSK2ForUpdates(callback)
        } else {
            subscribeSK1ForUpdates(callback)
        }
    }

    static func subscribeSK1ForUpdates(_ callback: @escaping (String) -> Void) {
        #if !os(visionOS)
            NotificationCenter.default.addObserver(forName: Notification.Name.SKStorefrontCountryCodeDidChange,
                                                   object: nil,
                                                   queue: nil) { _ in
                guard let countryCode = SKPaymentQueue.default().storefront?.countryCode else {
                    Log.warn("SKStorefrontManager (SK1): SKStorefrontCountryCodeDidChange to nil")
                    return
                }

                Log.verbose("SKStorefrontManager (SK1): SKStorefrontCountryCodeDidChange new value: \(countryCode)")

                callback(countryCode)
            }
        #endif
    }

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
