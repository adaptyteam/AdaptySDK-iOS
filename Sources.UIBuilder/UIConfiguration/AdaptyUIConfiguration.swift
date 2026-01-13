//
//  AdaptyUIConfiguration.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.01.2023
//

import Foundation

package typealias VC = AdaptyUIConfiguration

package struct AdaptyUIConfiguration: Sendable, Hashable {
    package let id: String
    package let locale: String
    package let isRightToLeft: Bool

    @available(*, deprecated, message: "use screens ")
    package var deprecated_defaultScreen: Screen { screens["default"]! }
    
    let assets: [String: Asset]
    package let screens: [String: Screen]
    package let scripts: [String]
}

extension AdaptyUIConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), locale: \(locale), isRightToLeft: \(isRightToLeft))"
    }
}
