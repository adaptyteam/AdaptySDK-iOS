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

        static let storeKit2Enabled: Bool = true // TODO: Remove

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
