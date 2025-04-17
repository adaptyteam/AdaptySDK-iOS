//
//  Log+default.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension Log {
    static let `default` = Log.Category(
        subsystem: "io.adapty",
        version: Adapty.SDKVersion,
        name: "sdk"
    )

    static let crossAB = Log.Category(name: "CrossAB")
    static let events = Log.Category(name: "Events")
    static let storage = Log.Category(name: "Storage")
    static let http = Log.Category(name: "API")

    static let fallbackPlacements = Log.Category(name: "FallbackPlacements")

    static let storeFront = Log.Category(name: "SKStorefront")
    static let sk1ProductManager = Log.Category(name: "SK1ProductsManager")
    static let sk2ProductManager = Log.Category(name: "SK2ProductsManager")

    static let sk1QueueManager = Log.Category(name: "SK1QueueManager")
    static let sk2TransactionManager = Log.Category(name: "SK2TransactionManager")

    static let skReceiptManager = Log.Category(name: "SKReceiptManager")
}
