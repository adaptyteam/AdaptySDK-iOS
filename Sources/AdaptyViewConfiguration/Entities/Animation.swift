//
//  Animation.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration {
    enum Animation: Sendable {
        case opacity(Timeline, DoubleValue)
        case offset(Timeline, OffsetValue)
        case rotation(Timeline, DoubleWithAnchorValue)
        case scale(Timeline, PointWithAnchorValue)
        case width(Timeline, UnitValue)
        case height(Timeline, UnitValue)
        case background(Timeline, FillingValue)
        case border(Timeline, FillingValue)
        case borderThickness(Timeline, DoubleValue)
        case shadow(Timeline, FillingValue)
        case shadowOffset(Timeline, OffsetValue)
        case shadowBlurRadius(Timeline, DoubleValue)
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
        case let .width(timeline, value):
            hasher.combine(5)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .height(timeline, value):
            hasher.combine(6)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .background(timeline, value):
            hasher.combine(7)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .border(timeline, value):
            hasher.combine(8)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .borderThickness(timeline, value):
            hasher.combine(9)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .shadow(timeline, value):
            hasher.combine(10)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .shadowOffset(timeline, value):
            hasher.combine(11)
            hasher.combine(timeline)
            hasher.combine(value)
        case let .shadowBlurRadius(timeline, value):
            hasher.combine(12)
            hasher.combine(timeline)
            hasher.combine(value)
        }
    }
}
