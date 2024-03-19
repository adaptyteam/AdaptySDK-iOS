//
//  AdaptyLogHandler.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

public typealias AdaptyLogHandler = (_ time: Date, _ level: AdaptyLogLevel, _ message: String) -> Void

extension Adapty {
    /// Override the default logger behavior using this method
    /// - Parameter handler: The function will be called for each message with the appropriate `logLevel`
    public static func setLogHandler(_ handler: @escaping AdaptyLogHandler) {
        AdaptyLogger.handler = handler
    }

    public static func writeLog(time: Date = Date(), level: AdaptyLogLevel, message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(time, level, { message }, file: file, function: function, line: line)
    }
}
