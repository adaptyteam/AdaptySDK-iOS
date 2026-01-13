//
//  VC.ColorGradient.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

package extension VC {
    struct ColorGradient: Sendable, Hashable {
        package let customId: String?
        package let kind: Kind
        package let start: Point
        package let end: Point
        package let items: [Item]
    }
}
