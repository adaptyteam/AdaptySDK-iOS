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
}
