//
//  Source.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

public extension AdaptyLogger {
    struct Source: Equatable, Sendable {
        public let fileName: String
        public let functionName: String
        public let lineNumber: UInt
    }
}

extension AdaptyLogger.Source: CustomStringConvertible {
    public var description: String { "\(fileName)#\(lineNumber)" }
}
