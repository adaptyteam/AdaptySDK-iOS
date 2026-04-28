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
    package let localizationId: LocaleId
    package let locale: Locale
    package let isRightToLeft: Bool
    package let environment: VC.EnvironmentConstants

    let assets: [AssetIdentifier: Asset]
    let strings: [StringIdentifier: RichText]

    let navigators: [NavigatorIdentifier: Navigator]
    let screens: [ScreenType: Screen]
    let scripts: [String]
}

extension AdaptyUIConfiguration: CustomStringConvertible {
    public var description: String {
        "(id: \(id), localizationId: \(localizationId), isRightToLeft: \(isRightToLeft))"
    }
}
