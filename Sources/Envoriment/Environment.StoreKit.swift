//
//  Environment.StoreKit.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.09.2024
//

import Foundation

extension Environment {
    enum StoreKit {
        static let name = "app_store"

        static let storeKit2Enabled: Bool =
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                true
            } else {
                false
            }

        @AdaptyActor
        private static var _lastStorefront: AdaptyStorefront?

        @AdaptyActor
        static var storefront: AdaptyStorefront? {
            get async {
                if let storefront = await AdaptyStorefront.current {
                    _lastStorefront = storefront
                    return storefront
                } else {
                    return _lastStorefront
                }
            }
        }
    }
}
