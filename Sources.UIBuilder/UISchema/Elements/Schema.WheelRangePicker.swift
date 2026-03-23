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

extension Schema.WheelRangePicker: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case maxValue = "max"
        case minValue = "min"
        case stepValue = "step"
        case format
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        value = try container.decode(Schema.Variable.self, forKey: .value)
        maxValue = try container.decode(Double.self, forKey: .maxValue)
        minValue = try container.decode(Double.self, forKey: .minValue)
        stepValue = try container.decodeIfPresent(Double.self, forKey: .stepValue) ?? 1.0

        let formatItems =
            if let stringId = try? container.decode(String.self, forKey: .format) {
                [Schema.RangeTextFormat.Item(from: 0, stringId: stringId)]
            } else {
                try container.decode([Schema.RangeTextFormat.Item].self, forKey: .format)
            }

        guard !formatItems.isEmpty else {
            throw DecodingError
                .dataCorruptedError(forKey: .format, in: container, debugDescription: "Must be at least one format item")
        }
        format = try .init(
            items: formatItems,
            textAttributes: Schema.TextAttributes(from: decoder)
        )
    }

    func encode(to encoder: any Encoder) throws {
        if let attributes = format.textAttributes {
            try attributes.encode(to: encoder)
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(value, forKey: .value)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(minValue, forKey: .minValue)
        if stepValue != 1.0 {
            try container.encode(stepValue, forKey: .stepValue)
        }

        if format.items.count == 1, format.items[0].from == 0 {
        } else {
            try container.encode(format.items, forKey: .format)
        }
    }
}
