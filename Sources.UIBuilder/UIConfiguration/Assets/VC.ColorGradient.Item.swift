//
//  VC.ColorGradient.Item.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension VC.ColorGradient {
    struct Item: Sendable, Hashable {
        let color: VC.Color
        let p: Double
    }
}
