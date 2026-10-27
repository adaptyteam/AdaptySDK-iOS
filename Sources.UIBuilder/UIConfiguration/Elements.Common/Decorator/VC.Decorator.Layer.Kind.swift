//
//  VC.Decorator.Layer.Kind.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 2.10.2026.
//

import Foundation

extension VC.Decorator.Layer {
    enum Kind: Sendable {
        case effects
        case fill(asset: VC.AssetReference)
        case stroke(asset: VC.AssetReference, thickness: Double)
        case image(asset: VC.AssetReference, aspect: VC.AspectRatio)
    }
}
