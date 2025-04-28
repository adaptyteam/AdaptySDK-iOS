//
//  AdaptyError.Source.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.09.2022.
//

import Foundation

public extension AdaptyError {
    struct Source: Sendable, Hashable {
        public let version = Adapty.SDKVersion
        public let file: String
        public let function: String
        public let line: UInt

        public init(file: String = #fileID, function: String = #function, line: UInt = #line) {
            self.file = file
            self.function = function
            self.line = line
        }
    }
}

extension AdaptyError.Source: CustomStringConvertible {
    public var description: String { "[\(version)]: \(file)#\(line)" }
}
