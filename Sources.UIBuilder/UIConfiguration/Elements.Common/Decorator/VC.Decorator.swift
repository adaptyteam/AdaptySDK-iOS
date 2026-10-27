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

// TODO: Remove all deprecated properties and structs

extension VC.Decorator {
    @available(*, deprecated)
    var deprecatedBackground: VC.AssetReference? { nil }
    @available(*, deprecated)
    var deprecatedBorder: VC.DeprecatedBorder? { nil }
    @available(*, deprecated)
    var deprecatedShadow: Shadow? { nil }
    @available(*, deprecated)
    var deprecatedInnerShadow: Shadow? { nil  }
}

extension VC {
    @available(*, deprecated)
    struct DeprecatedBorder: Sendable {
        let filling: AssetReference
        let thickness: Double
    }
}
