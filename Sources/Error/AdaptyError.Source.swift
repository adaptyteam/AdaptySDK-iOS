//
//  AdaptyError.Source.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.09.2022.
//

import Foundation

extension AdaptyError {
    public struct Source: Sendable, Hashable {
        public let version = Adapty.SDKVersion
        public let threadName: String
        public let file: String
        public let function: String
        public let line: UInt

        public init(threadName: String? = nil, file: String = #fileID, function: String = #function, line: UInt = #line) {
            self.threadName = threadName ?? Log.currentThreadName
            self.file = file
            self.function = function
            self.line = line
        }
    }
}

extension AdaptyError.Source: CustomStringConvertible {
    public var description: String {
        "[\(version)]: \(file)#\(line) thrd: \(threadName)"
    }
}
