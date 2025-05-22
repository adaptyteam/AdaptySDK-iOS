//
//  Log.Massage.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 22.08.2024
//

import Foundation

package extension Log {
    struct Message: Sendable, Hashable, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
        package typealias StringLiteralType = String

        package let value: String

        @inlinable
        package init(stringLiteral value: String) {
            self.value = value
        }
    }
}
