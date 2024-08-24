//
//  AdaptyLog.Source.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension Log {
    package typealias Source = AdaptyLog.Source
}

extension AdaptyLog {
    public struct Source: Equatable, Sendable {
        public let threadName: String
        public let fileName: String
        public let functionName: String
        public let lineNumber: UInt
    }
}

extension AdaptyLog.Source: CustomStringConvertible {
    public var description: String {
        "thrd: \(threadName), func: \(functionName)]\t \(fileName)#\(lineNumber)"
    }
}
