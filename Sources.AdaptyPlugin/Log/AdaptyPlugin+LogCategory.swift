//
//  AdaptyPlugin+LogCategory.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 19.11.2024.
//

import Adapty

public extension AdaptyPlugin {
    struct LogCategory {
        let wrapped: AdaptyLog.Category
        
        public init(subsystem: String, name: String) {
            wrapped = AdaptyLog.Category(subsystem: subsystem, version: Adapty.SDKVersion, name: name)
        }
        
        public func message(_ message: @autoclosure () -> String, withLevel level: AdaptyLog.Level, file: String = #fileID, function: String = #function, line: UInt = #line) {
            guard Log.isLevel(level) else { return }
            wrapped.write(message(), withLevel: level, file: file, function: function, line: line)
        }
        
        public func error(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
            guard Log.isLevel(.error) else { return }
            wrapped.write(message(), withLevel: .error, file: file, function: function, line: line)
        }
        
        public func warn(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
            guard Log.isLevel(.warn) else { return }
            wrapped.write(message(), withLevel: .warn, file: file, function: function, line: line)
        }
        
        public func info(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
            guard Log.isLevel(.info) else { return }
            wrapped.write(message(), withLevel: .info, file: file, function: function, line: line)
        }
        
        public func verbose(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
            guard Log.isLevel(.verbose) else { return }
            wrapped.write(message(), withLevel: .verbose, file: file, function: function, line: line)
        }
        
        public func debug(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {
            guard Log.isLevel(.debug) else { return }
            wrapped.write(message(), withLevel: .debug, file: file, function: function, line: line)
        }
    }
}
