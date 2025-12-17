//
//  VC.ColorGradient.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

package extension VC.ColorGradient {
    struct Item: Sendable, Hashable {
        package let color: VC.Color
        package let p: Double
    }
}
