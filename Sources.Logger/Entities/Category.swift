//
//  Category.swift
//  AdaptyLogger
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension AdaptyLogger {
    public struct Category: Sendable, Hashable {

        public let subsystem: String
        public let version: String
        public let name: String

        package init(subsystem: String? = nil, version: String, name: String) {
            self.subsystem = subsystem ?? "io.adapty"
            self.version = version
            self.name = name
        }
    }
}

extension AdaptyLogger.Category: CustomStringConvertible {
    public var description: String {
        if name == "sdk" {
            "[\(subsystem) v\(version)]"
        } else {
            "[\(subsystem) v\(version)] #\(name)#"
        }
    }
}
