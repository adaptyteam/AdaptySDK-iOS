//
//  Adapty.DeviceInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 02.06.2026.
//

import Foundation

package extension Adapty {
    struct DeviceInfo: Sendable {
        package let kind: DeviceKind
        package let vertical: Int
        package let horizontal: Int

        package init(kind: DeviceKind, vertical: Int, horizontal: Int) {
            self.kind = kind
            self.vertical = vertical
            self.horizontal = horizontal
        }
    }

    struct DeviceKind: RawRepresentable, Hashable, Sendable, Codable {
        package let rawValue: String

        package init(rawValue: String) {
            self.rawValue = rawValue.trimmed
        }

        package static let phone = DeviceKind(rawValue: "phone")
        package static let tab = DeviceKind(rawValue: "tab")
    }
}
