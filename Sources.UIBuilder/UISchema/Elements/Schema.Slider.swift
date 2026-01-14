//
//  Schema.Slider.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 14.01.2026.
//

import Foundation

extension Schema {
    typealias Slider = VC.Slider
}

extension Schema.Slider: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case maxValue = "max"
        case minValue = "min"
        case stepValue = "step"
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            value: container.decode(Schema.Variable.self, forKey: .value),
            maxValue: container.decode(Double.self, forKey: .maxValue),
            minValue: container.decode(Double.self, forKey: .minValue),
            stepValue: container.decodeIfPresent(Double.self, forKey: .stepValue)
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(stepValue, forKey: .stepValue)
    }
}
