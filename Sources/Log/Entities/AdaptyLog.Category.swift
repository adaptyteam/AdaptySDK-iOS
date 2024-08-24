//
//  AdaptyLog.Category.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 24.08.2024
//

import Foundation

extension Log {
    typealias Category = AdaptyLog.Category
}

public enum AdaptyLog {
    public struct Category: Sendable, Hashable {
        public let subsystem: String
        public let version: String
        public let name: String

        package init(subsystem: String? = nil, version: String? = nil, name: String) {
            self.subsystem = subsystem ?? Log.default.subsystem
            self.version = version ?? Log.default.version
            self.name = name
        }
    }
}

extension AdaptyLog.Category: CustomStringConvertible {
    public var description: String {
        if name == Log.default.name {
            "[\(subsystem) v\(version)]"
        } else {
            "[\(subsystem) v\(version)] #\(name)#"
        }
    }
}
