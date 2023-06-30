//
//  Shape.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 30.06.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    public struct Shape {
        static let defaultMask = Mask.rectangle(cornerRadius: 0.0)
        public let background: Filling?
        public let mask: Mask
    }
}

extension AdaptyUI.Shape {
    public enum Mask {
        case rectangle(cornerRadius: Double?)
        case circle
        case curveUp
        case curveDown
    }
}
