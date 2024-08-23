//
//  AdaptyLogLevel.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

public enum AdaptyLogLevel: Int, Sendable {
    public static let `default` = AdaptyLogLevel.info

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

extension AdaptyLogLevel: Comparable {
    public static func < (lhs: AdaptyLogLevel, rhs: AdaptyLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
