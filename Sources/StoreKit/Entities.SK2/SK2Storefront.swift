//
//  SK2Storefront.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import StoreKit

typealias SK2Storefront = Storefront

extension SK2Storefront {
    var asAdaptyStorefront: AdaptyStorefront {
        .init(id: id, countryCode: countryCode)
    }
}

private let log = Log.storeFront

extension AdaptyStorefront {
    enum StoreKit2 {
        static var current: AdaptyStorefront? {
            get async {
                await SK2Storefront.current?.asAdaptyStorefront
            }
        }

        static var updates: AsyncStream<AdaptyStorefront> {
            AsyncStream<AdaptyStorefront> { continuation in
                Task {
                    for await storefront in SK2Storefront.updates {
                        log.verbose("StoreKit2 Storefront.updates new value: \(storefront)")
                        continuation.yield(storefront.asAdaptyStorefront)
                    }
                    continuation.finish()
                }
            }
        }
    }
}
