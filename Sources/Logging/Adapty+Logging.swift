//
//  Adapty+Logging.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.09.2024
//

import Foundation

public extension Adapty {
    /// Set to the most appropriate level of logging
    nonisolated static var logLevel: AdaptyLog.Level {
        get { Log.level }
        set {
            Task {
                await Log.set(level: newValue)
            }
        }
    }

    /// Register the log handler to define the desired behavior, such as writing logs to files or sending them to your server.
    /// This will not override the default behavior but will add a new one.
    ///
    /// - Parameter handler: The function will be called for each message with the appropriate `logLevel`
    nonisolated static func setLogHandler(_ handler: AdaptyLog.Handler?) {
        Task {
            await Log.set(handler: handler)
        }
    }
}
