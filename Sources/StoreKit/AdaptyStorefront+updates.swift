//
//  AdaptyStorefront+updates.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import Foundation

public extension AdaptyStorefront {
    static var current: AdaptyStorefront? {
        get async {
            await AdaptyStorefront.StoreKit2.current
        }
    }

    static var updates: AsyncStream<AdaptyStorefront> {
        AdaptyStorefront.StoreKit2.updates
    }
}
