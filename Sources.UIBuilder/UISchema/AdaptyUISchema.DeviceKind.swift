//
//  AdaptyUISchema.DeviceKind.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 09.06.2026.
//

import Foundation

public extension AdaptyUISchema {
    struct DeviceKind: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let phone = DeviceKind(rawValue: "phone")
        public static let tab = DeviceKind(rawValue: "tab")
    }
}
