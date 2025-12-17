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
    package let templateId: String
    package let screen: Screen
    package let bottomSheets: [String: BottomSheet]
}

extension AdaptyUIConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), templateId: \(templateId), locale: \(locale), isRightToLeft: \(isRightToLeft))"
    }
}
