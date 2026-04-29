//
//  VC.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension VC {
    enum Animation: Sendable, Equatable {
        case opacity(Timeline, Range<Double>)
        case offset(Timeline, Range<Offset>)
        case rotation(Timeline, RotationParameters)
        case scale(Timeline, ScaleParameters)
        case box(Timeline, BoxParameters)
        case background(Timeline, Range<AssetReference>)
        case border(Timeline, BorderParameters)
        case shadow(Timeline, ShadowParameters)
        case innerShadow(Timeline, ShadowParameters)
        case blur(Timeline, Range<Double>)
    }
}

extension VC.Animation {
    var timeline: Timeline {
        switch self {
        case let .opacity(timeline, _):
            timeline
        case let .offset(timeline, _):
            timeline
        case let .rotation(timeline, _):
            timeline
        case let .scale(timeline, _):
            timeline
        case let .box(timeline, _):
            timeline
        case let .background(timeline, _):
            timeline
        case let .border(timeline, _):
            timeline
        case let .shadow(timeline, _):
            timeline
        case let .innerShadow(timeline, _):
            timeline
        case let .blur(timeline, _):
            timeline
        }
    }
}
