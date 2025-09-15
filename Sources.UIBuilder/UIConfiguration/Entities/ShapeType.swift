//
//  ShapeType.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

package extension AdaptyUIConfiguration {
    enum ShapeType: Sendable {
        case rectangle(cornerRadius: CornerRadius)
        case circle
        case curveUp
        case curveDown
    }
}

extension AdaptyUIConfiguration.ShapeType: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .rectangle(value):
            hasher.combine(1)
            hasher.combine(value)
        case .circle:
            hasher.combine(2)
        case .curveUp:
            hasher.combine(3)
        case .curveDown:
            hasher.combine(4)
        }
    }
}

extension AdaptyUIConfiguration.ShapeType: Codable {
    enum Types: String {
        case circle
        case rectangle = "rect"
        case curveUp = "curve_up"
        case curveDown = "curve_down"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try Types(rawValue: container.decode(String.self)) {
        case nil:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        case .curveUp:
            self = .curveUp
        case .curveDown:
            self = .curveDown
        case .rectangle:
            self =  .rectangle(cornerRadius: AdaptyUIConfiguration.CornerRadius.zero)
        case .circle:
            self = .circle
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .rectangle:
            try container.encode(Self.Types.rectangle.rawValue)
        case .circle:
            try container.encode(Self.Types.circle.rawValue)
        case .curveUp:
            try container.encode(Self.Types.curveUp.rawValue)
        case .curveDown:
            try container.encode(Self.Types.curveDown.rawValue)
        }
    }
}
