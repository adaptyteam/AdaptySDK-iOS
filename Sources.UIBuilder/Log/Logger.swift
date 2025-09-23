//
//  File.swift
//  Adapty
//
//  Created by Alexey Goncharov on 9/22/25.
//

import Foundation

enum Log {
    struct Category {
//        func message(_ message: @autoclosure () -> String, withLevel level: Log.Level, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
//        func message(_ message: @autoclosure () -> Log.Message, withLevel level: Log.Level, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
        func error(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {}

//        func error(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
        func warn(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
//        func warn(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
//        func info(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
//        func info(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
        func verbose(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
//        func verbose(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
//        func debug(_ message: @autoclosure () -> String, file: String = #fileID, function: String = #function, line: UInt = #line) {}
//
//        func debug(_ message: @autoclosure () -> Log.Message, file: String = #fileID, function: String = #function, line: UInt = #line) {}
    }

    static let cache: Category = .init()
    static let ui: Category = .init()
    static let prefetcher: Category = .init()
}

extension Log {
    fileprivate static let stampChars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")

    static var stamp: String {
        var result = ""
        for _ in 0 ..< 6 {
            result.append(Log.stampChars[Int(arc4random_uniform(62))])
        }
        return result
    }

    static func stamp(parent: String) -> String {
        "\(parent)/\(stamp)"
    }
}
