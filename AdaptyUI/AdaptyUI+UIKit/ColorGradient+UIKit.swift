//
//  ColorGradient+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension AdaptyUI.ColorGradient.Kind {
    var type: CAGradientLayerType {
        switch self {
        case .conic: return .conic
        case .linear: return .axial
        case .radial: return .radial
        }
    }
}

extension CAGradientLayer {
    static func create(_ asset: AdaptyUI.ColorGradient) -> CAGradientLayer {
        let layer = CAGradientLayer()

        layer.type = asset.kind.type
        layer.colors = asset.items.map { $0.color.uiColor.cgColor }
        layer.locations = asset.items.map { NSNumber(floatLiteral: $0.p) }
        layer.startPoint = asset.start.cgPoint
        layer.endPoint = asset.end.cgPoint

        return layer
    }
}
