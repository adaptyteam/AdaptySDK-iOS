//
//  Adapty.DeviceInfo.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 09.06.2026.
//

import AdaptyUIBuilder
import Foundation

package extension Adapty {
    typealias DeviceKind = AdaptyUISchema.DeviceKind
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
}
