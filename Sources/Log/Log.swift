//
//  Log+default.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import AdaptyLogger
import Foundation

enum Log {
    static var stamp: String {
        AdaptyLogger.stamp
    }

    nonisolated static func isLevel(_ level: AdaptyLogger.Level) -> Bool {
        AdaptyLogger.isLevel(level)
    }

    static func Category(name: String) -> AdaptyLogger.Category {
        AdaptyLogger.Category(
            subsystem: "io.adapty",
            version: Adapty.SDKVersion,
            name: "sdk"
        )
    }

    static let `default` = Log.Category(name: "sdk")

    static let crossAB = Log.Category(name: "CrossAB")
    static let events = Log.Category(name: "Events")
    static let storage = Log.Category(name: "Storage")
    static let http = Log.Category(name: "API")

    static let fallbackPlacements = Log.Category(name: "FallbackPlacements")

    static let storeFront = Log.Category(name: "Storefront")
    static let productManager = Log.Category(name: "ProductsManager")
    static let transactionManager = Log.Category(name: "TransactionManager")
    static let receiptManager = Log.Category(name: "ReceiptManager")
}
