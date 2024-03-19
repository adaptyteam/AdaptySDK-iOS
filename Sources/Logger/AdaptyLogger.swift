//
//  AdaptyLogger.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

enum AdaptyLogger {
    static var logLevel: AdaptyLogLevel = .info

    static var handler: AdaptyLogHandler = { NSLog("%@", $2) }

    private static let dispatchQueue = DispatchQueue(label: "Adapty.SDK.Logger")

    @inlinable static func write(_ time: Date, _ level: AdaptyLogLevel, _ message: @escaping () -> String, file: String, function _: String, line: UInt) {
        guard logLevel.rawValue >= level.rawValue else { return }
        if logLevel.rawValue >= AdaptyLogLevel.debug.rawValue {
            handler(time, level, "[Adapty v\(Adapty.SDKVersion)] - \(level)\t\(file)#\(line): \(message())")
        } else {
            handler(time, level, "[Adapty v\(Adapty.SDKVersion)] - \(level): \(message())")
        }
    }

    @inlinable static func asyncWrite(_ time: Date, _ level: AdaptyLogLevel, _ message: @escaping () -> String, file: String, function: String, line: UInt) {
        dispatchQueue.async { write(time, level, message, file: file, function: function, line: line) }
    }

    static func isLogLevel(_ level: AdaptyLogLevel) -> Bool {
        logLevel.rawValue >= level.rawValue
    }
}

enum Log {
    @inlinable static var stamp: String {
        var result = ""
        let base62chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        for _ in 0 ..< 6 {
            result.append(base62chars[Int.random(in: 0 ... 61)])
        }
        return result
    }

    @inlinable static func message(_ level: AdaptyLogLevel, _ message: @autoclosure @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), level, message, file: file, function: function, line: line)
    }

    @inlinable static func message(_ level: AdaptyLogLevel, message: @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), level, message, file: file, function: function, line: line)
    }

    @inlinable static func error(_ message: @autoclosure @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .error, message, file: file, function: function, line: line)
    }

    @inlinable static func error(message: @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .error, message, file: file, function: function, line: line)
    }

    @inlinable static func warn(_ message: @autoclosure @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .warn, message, file: file, function: function, line: line)
    }

    @inlinable static func warn(message: @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .warn, message, file: file, function: function, line: line)
    }

    @inlinable static func info(_ message: @autoclosure @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .info, message, file: file, function: function, line: line)
    }

    @inlinable static func info(message: @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .info, message, file: file, function: function, line: line)
    }

    @inlinable static func verbose(_ message: @autoclosure @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .verbose, message, file: file, function: function, line: line)
    }

    @inlinable static func verbose(message: @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .verbose, message, file: file, function: function, line: line)
    }

    @inlinable static func debug(_ message: @autoclosure @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .debug, message, file: file, function: function, line: line)
    }

    @inlinable static func debug(message: @escaping () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(Date(), .debug, message, file: file, function: function, line: line)
    }
}
