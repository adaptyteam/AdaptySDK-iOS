//
//  AdaptyLogger.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

extension Adapty {
    public enum LogLevel: Int {
        /// Only errors will be logged
        case error
        /// `.error` +  messages from the SDK that do not cause critical errors, but are worth paying attention to
        case warn
        /// `.warn` +  information messages, such as those that log the lifecycle of various modules
        case info
        /// `.info` + any additional information that may be useful during debugging, such as function calls, API queries, etc.
        case verbose
        /// Debug purposes logging level
        case debug
    }

    /// Set to the most appropriate level of logging
    public static var logLevel: Adapty.LogLevel {
        get { AdaptyLogger.logLevel }
        set { AdaptyLogger.logLevel = newValue }
    }
}

extension Adapty.LogLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .error: return "ERROR"
        case .warn: return "WARN"
        case .info: return "INFO"
        case .verbose: return "VERBOSE"
        case .debug: return "DEBUG"
        }
    }
}
