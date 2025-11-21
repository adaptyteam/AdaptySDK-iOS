//
//  Log.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

public enum AdaptyLogger {
    @globalActor
    package actor InternalActor {
        package static let shared = InternalActor()
    }

    package nonisolated(unsafe) static var level: Level = .default

    package nonisolated static func isLevel(_ level: Level) -> Bool {
        self.level >= level
    }

    @InternalActor
    package static func set(level: Level) async {
        self.level = level
    }

    @InternalActor
    private(set) static var handler: Handler?

    @InternalActor
    package static func set(handler: Handler?) async {
        Self.handler = handler
    }

    @InternalActor
    private static func handlerWrite(_ record: Record) {
        handler?(record)
    }

    fileprivate static func write(record: Record) {
        Task.detached(priority: .utility) {
            await osLogWrite(record)
            await handlerWrite(record)
        }
    }
}

package extension AdaptyLogger.Category {
    func write(
        _ message: String,
        withLevel level: AdaptyLogger.Level,
        file: String,
        function: String,
        line: UInt
    ) {
        AdaptyLogger.write(record: .init(
            date: Date(),
            level: level,
            message: message,
            category: self,
            source: .init(
                fileName: file,
                functionName: function,
                lineNumber: line
            )
        ))
    }
}

package extension AdaptyLogger.Category {
    func message(_ message: @autoclosure () -> String, withLevel level: AdaptyLogger.Level, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(level) else { return }
        write(message(), withLevel: level, file: file, function: function, line: line)
    }

    func message(_ message: @autoclosure () -> AdaptyLogger.Message, withLevel level: AdaptyLogger.Level, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(level) else { return }
        write(message().value, withLevel: level, file: file, function: function, line: line)
    }

    func error(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.error) else { return }
        write(message(), withLevel: .error, file: file, function: function, line: line)
    }

    func error(_ message: @autoclosure () -> AdaptyLogger.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.error) else { return }
        write(message().value, withLevel: .error, file: file, function: function, line: line)
    }

    func warn(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.warn) else { return }
        write(message(), withLevel: .warn, file: file, function: function, line: line)
    }

    func warn(_ message: @autoclosure () -> AdaptyLogger.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.warn) else { return }
        write(message().value, withLevel: .warn, file: file, function: function, line: line)
    }

    func info(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.info) else { return }
        write(message(), withLevel: .info, file: file, function: function, line: line)
    }

    func info(_ message: @autoclosure () -> AdaptyLogger.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.info) else { return }
        write(message().value, withLevel: .info, file: file, function: function, line: line)
    }

    func verbose(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.verbose) else { return }
        write(message(), withLevel: .verbose, file: file, function: function, line: line)
    }

    func verbose(_ message: @autoclosure () -> AdaptyLogger.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.verbose) else { return }
        write(message().value, withLevel: .verbose, file: file, function: function, line: line)
    }

    func debug(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.debug) else { return }
        write(message(), withLevel: .debug, file: file, function: function, line: line)
    }

    func debug(_ message: @autoclosure () -> AdaptyLogger.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard AdaptyLogger.isLevel(.debug) else { return }
        write(message().value, withLevel: .debug, file: file, function: function, line: line)
    }
}
