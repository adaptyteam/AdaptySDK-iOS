//
//  VC.Decorator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

extension VC {
    struct Decorator: Sendable, Hashable {
        let shapeType: ShapeType
        let background: AssetReference?
        let border: Border?
        let shadow: Shadow?
        let blurRadius: Double?
    }
}
