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

extension Schema.Slider: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .slider(self, properties)
    }
}

extension Schema.Slider: Decodable {
    enum CodingKeys: String, CodingKey {
        case value
        case maxValue = "max"
        case minValue = "min"
        case stepValue = "step"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            value: container.decode(Schema.Variable.self, forKey: .value),
            maxValue: container.decode(Double.self, forKey: .maxValue),
            minValue: container.decode(Double.self, forKey: .minValue),
            stepValue: container.decodeIfPresent(Double.self, forKey: .stepValue) ?? 1.0
        )
    }
}

