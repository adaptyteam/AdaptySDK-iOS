//
//  Log.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

package enum Log {
    @globalActor
    package actor InternalActor {
        package static let shared = InternalActor()
    }

    #if compiler(>=5.10)

        package nonisolated(unsafe) static var level: Level = .default

        package nonisolated static func isLevel(_ level: Level) -> Bool {
            self.level >= level
        }

        @InternalActor
        static func set(level: Level) async {
            self.level = level
        }
    #else
        private final class NonisolatedUnsafe: @unchecked Sendable {
            var level: Level = .default
        }

        private nonisolated static let _nonisolatedUnsafe = NonisolatedUnsafe()

        package nonisolated static var level: Level {
            _nonisolatedUnsafe.level
        }

        package nonisolated static func isLevel(_ level: Level) -> Bool {
            _nonisolatedUnsafe.level >= level
        }

        @InternalActor
        static func set(level: Level) async {
            _nonisolatedUnsafe.level = level
        }
    #endif

    @InternalActor
    private(set) static var handler: Handler?

    @InternalActor
    static func set(handler: Handler?) async {
        Log.handler = handler
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

package extension Log.Category {
    func write(
        _ message: String,
        withLevel level: Log.Level,
        file: String,
        function: String,
        line: UInt
    ) {
        Log.write(record: .init(
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

package extension Log.Category {
    func message(_ message: @autoclosure () -> String, withLevel level: Log.Level, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(level) else { return }
        write(message(), withLevel: level, file: file, function: function, line: line)
    }

    func message(_ message: @autoclosure () -> Log.Message, withLevel level: Log.Level, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(level) else { return }
        write(message().value, withLevel: level, file: file, function: function, line: line)
    }

    func error(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.error) else { return }
        write(message(), withLevel: .error, file: file, function: function, line: line)
    }

    func error(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.error) else { return }
        write(message().value, withLevel: .error, file: file, function: function, line: line)
    }

    func warn(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.warn) else { return }
        write(message(), withLevel: .warn, file: file, function: function, line: line)
    }

    func warn(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.warn) else { return }
        write(message().value, withLevel: .warn, file: file, function: function, line: line)
    }

    func info(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.info) else { return }
        write(message(), withLevel: .info, file: file, function: function, line: line)
    }

    func info(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.info) else { return }
        write(message().value, withLevel: .info, file: file, function: function, line: line)
    }

    func verbose(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.verbose) else { return }
        write(message(), withLevel: .verbose, file: file, function: function, line: line)
    }

    func verbose(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.verbose) else { return }
        write(message().value, withLevel: .verbose, file: file, function: function, line: line)
    }

    func debug(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.debug) else { return }
        write(message(), withLevel: .debug, file: file, function: function, line: line)
    }

    func debug(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {
        guard Log.isLevel(.debug) else { return }
        write(message().value, withLevel: .debug, file: file, function: function, line: line)
    }
}
