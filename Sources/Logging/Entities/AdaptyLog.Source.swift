//
//  AdaptyLog.Source.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

package extension Log {
    typealias Source = AdaptyLog.Source
}

public extension AdaptyLog {
    struct Source: Equatable, Sendable {
        public let fileName: String
        public let functionName: String
        public let lineNumber: UInt
    }
}

extension AdaptyLog.Source: CustomStringConvertible {
    public var description: String { "\(fileName)#\(lineNumber)" }
}
