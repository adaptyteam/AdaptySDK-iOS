//
//  Schema.WheelRangePicker.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema {
    struct WheelRangePicker: Sendable {
        let value: Variable
        let maxValue: Double
        let minValue: Double
        let stepValue: Double
        let format: Schema.RangeTextFormat
    }
}

extension Schema.WheelRangePicker: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .wheelRangePicker(
            .init(
                value: value,
                maxValue: maxValue,
                minValue: minValue,
                stepValue: stepValue,
                format: builder.convertRangeTextFormat(format)
            ),
            properties
        )
    }
}

extension Schema.WheelRangePicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case value
        case maxValue = "max"
        case minValue = "min"
        case stepValue = "step"
        case format
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            value: container.decode(Schema.Variable.self, forKey: .value),
            maxValue: container.decode(Double.self, forKey: .maxValue),
            minValue: container.decode(Double.self, forKey: .minValue),
            stepValue: container.decodeIfPresent(Double.self, forKey: .stepValue) ?? 1.0,

            format: container.decodeRangeTextFormat(
                textAttributes: .init(from: decoder),
                forKey: .format
            )
        )
    }
}

