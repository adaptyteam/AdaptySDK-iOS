//
//  AdaptyStorefront+updates.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.09.2024
//

import Foundation

extension AdaptyStorefront {
    public static var current: AdaptyStorefront? {
        get async {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
                await AdaptyStorefront.StoreKit2.current
            } else {
                await AdaptyStorefront.StoreKit1.current
            }
        }
    }

    public static var updates: AsyncStream<AdaptyStorefront> {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *) {
            AdaptyStorefront.StoreKit2.updates
        } else {
            AdaptyStorefront.StoreKit1.updates
        }
    }
}
