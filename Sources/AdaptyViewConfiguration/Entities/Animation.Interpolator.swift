//
//  Animation.Interpolator.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    enum Interpolator: Sendable {
        static let `default` = Self.easeInOut

        case easeInOut
        case easeIn
        case easeOut
        case linear
        case cubicBezier(Double, Double, Double, Double)
    }
}

extension AdaptyViewConfiguration.Animation.Interpolator: Hashable {
    package func hash(into hasher: inout Hasher) {
        switch self {
        case .easeInOut:
            hasher.combine(1)
        case .easeIn:
            hasher.combine(2)
        case .easeOut:
            hasher.combine(3)
        case .linear:
            hasher.combine(4)
        case let .cubicBezier(x1, x2, x3, x4):
            hasher.combine(5)
            hasher.combine(x1)
            hasher.combine(x2)
            hasher.combine(x3)
            hasher.combine(x4)
        }
    }
}

extension AdaptyViewConfiguration.Animation.Interpolator: Codable {
    enum Values: String {
        case easeInOut = "ease_in_out"
        case easeIn = "ease_in"
        case easeOut = "ease_out"
        case linear
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let values = try? container.decode([Double].self) {
            guard values.count == 4 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Wrong format of cubic bezier interpolator, need 4 values but get \(values.count)"))
            }
            self = .cubicBezier(values[0], values[1], values[2], values[3])
            return
        }

        let value = try container.decode(String.self)
        switch Values(rawValue: value) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Interpolator name \(value)'"))
        case .easeInOut:
            self = .easeInOut
        case .easeIn:
            self = .easeIn
        case .easeOut:
            self = .easeOut
        case .linear:
            self = .linear
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .easeInOut:
            try container.encode(Values.easeInOut.rawValue)
        case .easeIn:
            try container.encode(Values.easeIn.rawValue)
        case .easeOut:
            try container.encode(Values.easeOut.rawValue)
        case .linear:
            try container.encode(Values.linear.rawValue)
        case let .cubicBezier(x1, x2, x3, x4):
            try container.encode([x1, x2, x3, x4])
        }
    }
}
