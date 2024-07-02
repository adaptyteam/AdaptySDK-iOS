//
//  ShapeType.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    package enum ShapeType: Sendable {
        case rectangle(cornerRadius: CornerRadius)
        case circle
        case curveUp
        case curveDown
    }
}

extension AdaptyUI.ShapeType: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case let .rectangle(value):
            hasher.combine(value)
        case .circle, .curveUp, .curveDown:
            break
        }
    }
}

extension AdaptyUI.ShapeType: Decodable {
    enum Types: String {
        case circle
        case rectangle = "rect"
        case curveUp = "curve_up"
        case curveDown = "curve_down"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try Types(rawValue: container.decode(String.self)) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        case .curveUp:
            self = .curveUp
        case .curveDown:
            self = .curveDown
        case .rectangle:
            self = .rectangle(cornerRadius: AdaptyUI.CornerRadius.zero)
        case .circle:
            self = .circle
        }
    }
}
