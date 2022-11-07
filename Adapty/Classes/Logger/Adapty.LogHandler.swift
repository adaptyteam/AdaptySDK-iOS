//
//  AdaptyLogger.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

extension Adapty {
    public typealias LogHandler = (_ level: Adapty.LogLevel, _ message: String) -> Void

    /// Override the default logger behavior using this method
    /// - Parameter handler: The function will be called for each message with the appropriate `logLevel`
    public static func setLogHandler(_ handler: @escaping Adapty.LogHandler) {
        AdaptyLogger.handler = handler
    }
}
