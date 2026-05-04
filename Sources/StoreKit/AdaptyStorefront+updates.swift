//
//  AdaptyStorefront+updates.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.11.2025.
//

import StoreKit

private let log = Log.storeFront

public extension AdaptyStorefront {
    static var current: AdaptyStorefront? {
        get async {
            await StoreKit.Storefront.current?.asAdaptyStorefront
        }
    }

    static var updates: AsyncStream<AdaptyStorefront> {
        AsyncStream<AdaptyStorefront> { continuation in
            Task {
                for await storefront in StoreKit.Storefront.updates {
                    log.verbose("StoreKit.Storefront.updates new value: \(storefront)")
                    continuation.yield(storefront.asAdaptyStorefront)
                }
                continuation.finish()
            }
        }
    }
}
