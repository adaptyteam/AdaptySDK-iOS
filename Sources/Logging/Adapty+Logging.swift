//
//  Adapty+Logging.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 25.09.2024
//

import Foundation

extension Adapty {
    /// Set to the most appropriate level of logging
    public nonisolated static var logLevel: AdaptyLog.Level {
        get { Log.level }
        set {
            Task {
                await Log.set(level: newValue)
            }
        }
    }

    /// Override the default logger behavior using this method
    /// - Parameter handler: The function will be called for each message with the appropriate `logLevel`
    public nonisolated static func setLogHandler(_ handler: AdaptyLog.Handler?) { 
        // TODO: Change comment.  Does not override the default behavior of the logger
        Task {
            await Log.set(handler: handler)
        }
    }
}
