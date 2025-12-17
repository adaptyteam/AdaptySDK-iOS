//
//  Schema.Animation.Interpolator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

extension Schema.Animation {
    typealias Interpolator = VC.Animation.Interpolator
}

extension Schema.Animation.Interpolator {
    static let `default` = Self.easeInOut
}

extension Schema.Animation.Interpolator: Codable {
    enum Values: String {
        case easeInOut = "ease_in_out"
        case easeIn = "ease_in"
        case easeOut = "ease_out"
        case linear
        case easeInElastic = "ease_in_elastic"
        case easeOutElastic = "ease_out_elastic"
        case easeInOutElastic = "ease_in_out_elastic"
        case easeInBounce = "ease_in_bounce"
        case easeOutBounce = "ease_out_bounce"
        case easeInOutBounce = "ease_in_out_bounce"
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
        case nil:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Interpolator name \(value)'"))
        case .easeInOut:
            self = .easeInOut
        case .easeIn:
            self = .easeIn
        case .easeOut:
            self = .easeOut
        case .linear:
            self = .linear
        case .easeInElastic:
            self = .easeInElastic
        case .easeOutElastic:
            self = .easeOutElastic
        case .easeInOutElastic:
            self = .easeInOutElastic
        case .easeInBounce:
            self = .easeInBounce
        case .easeOutBounce:
            self = .easeOutBounce
        case .easeInOutBounce:
            self = .easeInOutBounce
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
        case .easeInElastic:
            try container.encode(Values.easeInElastic.rawValue)
        case .easeOutElastic:
            try container.encode(Values.easeOutElastic.rawValue)
        case .easeInOutElastic:
            try container.encode(Values.easeInOutElastic.rawValue)
        case .easeInBounce:
            try container.encode(Values.easeInBounce.rawValue)
        case .easeOutBounce:
            try container.encode(Values.easeOutBounce.rawValue)
        case .easeInOutBounce:
            try container.encode(Values.easeInOutBounce.rawValue)
        case let .cubicBezier(x1, x2, x3, x4):
            try container.encode([x1, x2, x3, x4])
        }
    }
}
