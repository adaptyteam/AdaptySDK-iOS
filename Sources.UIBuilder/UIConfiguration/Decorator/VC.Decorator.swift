//
//  VC.Decorator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.03.2024
//

import Foundation

package extension VC {
    struct Decorator: Sendable, Hashable {
        package let shapeType: ShapeType
        package let background: AssetReference?
        package let border: Border?
        package let shadow: Shadow?
    }
}
