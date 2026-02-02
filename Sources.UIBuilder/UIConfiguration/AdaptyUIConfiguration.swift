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

    let assets: [AssetIdentifier: Asset]
    let strings: [StringIdentifier: RichText]

    package let navigators: [NavigatorIdentifier: Navigator]
    package let screens: [ScreenType: Screen]
    let scripts: [String]
}

extension AdaptyUIConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), locale: \(locale), isRightToLeft: \(isRightToLeft))"
    }
}
