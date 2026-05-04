//
//  VC.ColorGradient.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

package extension VC {
    struct ColorGradient: Sendable, Hashable {
        let customId: String?
        let kind: Kind
        let start: Point
        let end: Point
        let items: [Item]
    }
}
