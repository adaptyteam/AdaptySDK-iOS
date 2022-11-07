//
//  AdaptyLogger.swift
//  Adapty
//
//  Created by Aleksei Valiano on 23.10.2022.
//

import Foundation

enum AdaptyLogger {
    static var logLevel: Adapty.LogLevel = .info

    static var handler: Adapty.LogHandler = { NSLog("%@", $1) }

    private static let dispatchQueue = DispatchQueue(label: "Adapty.SDK.Logger")

    @inlinable static func write(_ level: Adapty.LogLevel, _ message: String, file: String, function: String, line: UInt) {
        guard logLevel.rawValue >= level.rawValue else { return }
        if logLevel.rawValue >= Adapty.LogLevel.debug.rawValue {
            handler(level, "[Adapty v\(Adapty.SDKVersion)] - \(level)\t\(file)#\(line): \(message)")
        } else {
            handler(level, "[Adapty v\(Adapty.SDKVersion)] - \(level): \(message)")
        }
    }

    @inlinable static func asyncWrite(_ level: Adapty.LogLevel, _ message: String, file: String, function: String, line: UInt) {
        dispatchQueue.async { write(level, message, file: file, function: function, line: line) }
    }
}

enum Log {
    @inlinable static var stamp: String {
        var result = ""
        let base62chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        for _ in 0 ..< 6 {
            result.append(base62chars[Int(arc4random_uniform(62))])
        }
        return result
    }

    @inlinable static func message(_ level: Adapty.LogLevel, _ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(level, message, file: file, function: function, line: line)
    }

    @inlinable static func error(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.error, message, file: file, function: function, line: line)
    }

    @inlinable static func error(_ message: CustomStringConvertible, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.error, message.description, file: file, function: function, line: line)
    }

    @inlinable static func warn(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.warn, message, file: file, function: function, line: line)
    }

    @inlinable static func warn(_ message: CustomStringConvertible, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.warn, message.description, file: file, function: function, line: line)
    }

    @inlinable static func info(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.info, message, file: file, function: function, line: line)
    }

    @inlinable static func info(_ message: CustomStringConvertible, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.info, message.description, file: file, function: function, line: line)
    }

    @inlinable static func verbose(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.verbose, message, file: file, function: function, line: line)
    }

    @inlinable static func verbose(_ message: CustomStringConvertible, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.verbose, message.description, file: file, function: function, line: line)
    }

    @inlinable static func debug(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.debug, message, file: file, function: function, line: line)
    }

    @inlinable static func debug(_ message: CustomStringConvertible, file: String = #fileID, function: String = #function, line: UInt = #line) {
        AdaptyLogger.asyncWrite(.debug, message.description, file: file, function: function, line: line)
    }
}
