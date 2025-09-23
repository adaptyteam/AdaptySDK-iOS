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

    static let storeFront = Log.Category(name: "SKStorefront")
    static let sk1ProductManager = Log.Category(name: "SK1ProductsManager")
    static let sk2ProductManager = Log.Category(name: "SK2ProductsManager")

    static let sk1QueueManager = Log.Category(name: "SK1QueueManager")
    static let sk2TransactionManager = Log.Category(name: "SK2TransactionManager")

    static let skReceiptManager = Log.Category(name: "SKReceiptManager")
}

public enum AdaptyLog {
    public typealias Handler = AdaptyLogger.Handler
    public typealias Level = AdaptyLogger.Level
}

public extension Adapty {
    /// Set to the most appropriate level of logging
    nonisolated static var logLevel: AdaptyLog.Level {
        get { AdaptyLogger.level }
        set {
            Task {
                await AdaptyLogger.set(level: newValue)
            }
        }
    }

    /// Register the log handler to define the desired behavior, such as writing logs to files or sending them to your server.
    /// This will not override the default behavior but will add a new one.
    ///
    /// - Parameter handler: The function will be called for each message with the appropriate `logLevel`
    nonisolated static func setLogHandler(_ handler: AdaptyLog.Handler?) {
        Task {
            await AdaptyLogger.set(handler: handler)
        }
    }
}
