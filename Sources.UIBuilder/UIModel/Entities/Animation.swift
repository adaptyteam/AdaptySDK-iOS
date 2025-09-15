//
//  Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    enum Animation: Sendable {
        case opacity(Timeline, Animation.Range<Double>)
        case offset(Timeline, Animation.Range<Offset>)
        case rotation(Timeline, Animation.RotationParameters)
        case scale(Timeline, ScaleParameters)
        case box(Timeline, BoxParameters)
        case background(Timeline, Animation.Range<Mode<Filling>>)
        case border(Timeline, BorderParameters)
        case shadow(Timeline, ShadowParameters)
    }
}

package extension AdaptyViewConfiguration.Animation {
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
        }
    }
}

extension AdaptyViewConfiguration.Animation: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .opacity(timeline, value):
            hasher.combine(1)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .offset(timeline, value):
            hasher.combine(2)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .rotation(timeline, value):
            hasher.combine(3)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .scale(timeline, value):
            hasher.combine(4)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .box(timeline, value):
            hasher.combine(5)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .background(timeline, value):
            hasher.combine(6)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .border(timeline, value):
            hasher.combine(7)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .shadow(timeline, value):
            hasher.combine(8)
            hasher.combine(timeline)
            hasher.combine(value)
        }
    }
}
