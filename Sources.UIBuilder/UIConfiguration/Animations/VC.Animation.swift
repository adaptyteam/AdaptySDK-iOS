//
//  VC.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension VC {
    struct Animation: Sendable, Identifiable {
        let id = UUID()
        let timeline: Timeline
        let kind: Kind
    }
}

extension VC.Animation: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension VC.Animation {
    enum Kind: Sendable {
        case opacity(Range<Double>)
        case offset(Range<VC.Offset>)
        case rotation(RotationParameters)
        case scale(ScaleParameters)
        case box(BoxParameters)
        case background(Range<VC.AssetReference>)
        case border(BorderParameters)
        case shadow(ShadowParameters)
        case innerShadow(ShadowParameters)
        case blur(Range<Double>)
    }
}
