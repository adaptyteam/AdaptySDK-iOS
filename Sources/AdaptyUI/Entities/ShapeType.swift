//
//  ShapeType.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public enum ShapeType {
        case rectangle(cornerRadius: Shape.CornerRadius)
        case circle
        case curveUp
        case curveDown
    }
}
