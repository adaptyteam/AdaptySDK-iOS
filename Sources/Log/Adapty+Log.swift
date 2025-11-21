//
//  AdaptyLog.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.09.2025.
//

import AdaptyLogger

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
