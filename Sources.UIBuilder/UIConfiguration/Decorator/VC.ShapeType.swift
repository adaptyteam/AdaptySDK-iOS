//
//  VC.ShapeType.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

package extension VC {
    enum ShapeType: Sendable, Hashable {
        case rectangle(cornerRadius: CornerRadius)
        case circle
        case curveUp
        case curveDown
    }
}

