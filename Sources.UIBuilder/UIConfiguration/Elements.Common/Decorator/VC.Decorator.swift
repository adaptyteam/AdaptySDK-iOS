//
//  VC.Decorator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension VC {
    struct Decorator: Sendable {
        let shapeType: ShapeType
        let overlays: [Layer]
        let underlays: [Layer]
        let blurRadius: Double?
        let clip: Clip
    }
}
