//
//  SK1Storefront.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

typealias SK1Storefront = SKStorefront

extension SK1Storefront {
    var asAdaptyStorefront: AdaptyStorefront {
        .init(id: identifier, countryCode: countryCode)
    }
}

private let log = Log.Category(name: "AdaptyStorefront")

extension AdaptyStorefront {
    enum StoreKit1 {
        static var current: AdaptyStorefront? {
            get async {
                await MainActor.run {
                    SKPaymentQueue.default().storefront?.asAdaptyStorefront
                }
            }
        }

        static var updates: AsyncStream<AdaptyStorefront> {
            AsyncStream<AdaptyStorefront> { continuation in
                #if os(visionOS)
                    continuation.finish()
                #else
                    Task<Void, Never> {
                        NotificationCenter.default.addObserver(
                            forName: Notification.Name.SKStorefrontCountryCodeDidChange,
                            object: nil,
                            queue: nil
                        ) { _ in
                            if let storefront = SKPaymentQueue.default().storefront {
                                log.verbose("Notifications SKStorefrontCountryCodeDidChange: value is \(storefront)")
                                continuation.yield(storefront.asAdaptyStorefront)
                            } else {
                                log.warn("Notifications SKStorefrontCountryCodeDidChange: value is nil")
                            }
                        }
                    }
                #endif
            }
        }
    }
}
