//
//  Log.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

extension Adapty {
    /// Set to the most appropriate level of logging
    public static var logLevel: AdaptyLogLevel {
        get { Log.level }
        set {
            Task {
                await Log.set(level: newValue)
            }
        }
    }

    /// Override the default logger behavior using this method
    /// - Parameter handler: The function will be called for each message with the appropriate `logLevel`
    public static func setLogHandler(_ handler: @escaping AdaptyLogHandler) {
        Task {
            await Log.set(handler: handler)
        }
    }
}

package enum Log {
    private final class Storage: @unchecked Sendable {
        var level: AdaptyLogLevel = .default
    }

    private static let _storage = Storage()

    @inlinable
    package static var level: AdaptyLogLevel {
        _storage.level
    }

    package static func isLevel(_ level: AdaptyLogLevel) -> Bool {
        self.level >= level
    }

    @InternalActor
    private(set) static var handler: AdaptyLogHandler = Log.defaultLogHandler

    @InternalActor
    static func set(level: AdaptyLogLevel) async {
        _storage.level = level
    }

    @InternalActor
    static func set(handler: @escaping AdaptyLogHandler) async {
        Log.handler = handler
    }

    @InternalActor
    private static func write(record: AdaptyLogRecord) {
        handler(record)
    }

    private static func write(
        message: String,
        withLevel level: AdaptyLogLevel,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        guard self.level >= level else { return }
        let record = AdaptyLogRecord(
            date: Date(),
            level: level,
            value: message,
            source: .init(
                sdkVersion: Adapty.SDKVersion,
                threadName: Log.currentThreadName,
                fileName: file,
                functionName: function,
                lineNumber: line
            )
        )
        Task.detached(priority: .utility) {
            await Log.write(record: record)
        }
    }

    @inlinable
    package nonisolated static func message(
        _ message: @autoclosure () -> String,
        withLevel level: AdaptyLogLevel,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.write(
            message: message(),
            withLevel: level,
            file: file,
            function: function,
            line: line
        )
    }

    @inlinable
    package nonisolated static func message(
        _ message: @autoclosure () -> Message,
        withLevel level: AdaptyLogLevel,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        self.write(
            message: message().value,
            withLevel: level,
            file: file,
            function: function,
            line: line
        )
    }
}

package extension Log {
    @inlinable
    nonisolated static func error(_ message: @autoclosure () -> Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .error, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func error(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .error, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func warn(_ message: @autoclosure () -> Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .warn, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func warn(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .warn, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func info(_ message: @autoclosure () -> Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .info, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func info(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .info, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func verbose(_ message: @autoclosure () -> Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .verbose, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func verbose(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .verbose, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func debug(_ message: @autoclosure () -> Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .debug, file: file, function: function, line: line)
    }

    @inlinable
    nonisolated static func debug(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        Log.message(message(), withLevel: .debug, file: file, function: function, line: line)
    }
}
