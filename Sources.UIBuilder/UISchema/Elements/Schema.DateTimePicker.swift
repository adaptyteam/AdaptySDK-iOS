//
//  Schema.DateTimePicker.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema {
    typealias DateTimePicker = VC.DateTimePicker
}

extension Schema.DateTimePicker: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        .dateTimePicker(self, properties)
    }
}

extension Schema.DateTimePicker: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case value
        case components
        case maxDate = "max"
        case minDate = "min"
        case color
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(Schema.Element.ContentType.self, forKey: .type)
        switch type {
        case .compactDateTimePicker:
            kind = .compact
        case .wheelDateTimePicker:
            kind = .wheel
        case .graphicalDateTimePicker:
            kind = .graphical
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.type],
                    debugDescription: "unknown datetime picker type '\(type)'"
                )
            )
        }

        value = try container.decode(Schema.Variable.self, forKey: .value)
        components = try container.decode(Schema.DateTimePicker.Components.self, forKey: .components)
        maxDate = try container.decodeDateTimeIfPresent(forKey: .maxDate)
        minDate = try container.decodeDateTimeIfPresent(forKey: .minDate)
        color = try container.decodeIfPresent(Schema.AssetReference.self, forKey: .color)
    }

}
