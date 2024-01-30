//
//  SKStoreFrontManager.swift
//
//
//  Created by Aleksey Goncharov on 30.1.24..
//

import Foundation
import StoreKit

protocol StorefrontManager {
    func fetchStoreCountry(_ callback: @escaping (String?) -> Void)
    func subscribeForUpdates(_ callback: @escaping (String) -> Void)
}

@available(iOS 13.0, *)
class SKStorefrontManager: StorefrontManager {
    func fetchStoreCountry(_ callback: @escaping (String?) -> Void) {
        callback(SKPaymentQueue.default().storefront?.countryCode)
    }

    func subscribeForUpdates(_ callback: @escaping (String) -> Void) {
        #if os(iOS)
            NotificationCenter.default.addObserver(forName: Notification.Name.SKStorefrontCountryCodeDidChange,
                                                   object: nil,
                                                   queue: nil) { _ in
                guard let countryCode = SKPaymentQueue.default().storefront?.countryCode else {
                    Log.warn("SKStorefrontManager: SKStorefrontCountryCodeDidChange to nil")
                    return
                }

                Log.verbose("SKStorefrontManager: SKStorefrontCountryCodeDidChange new value: \(countryCode)")

                callback(countryCode)
            }
        #endif
    }
}
