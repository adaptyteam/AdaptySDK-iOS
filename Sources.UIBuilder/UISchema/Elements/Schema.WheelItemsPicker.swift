//
//  Schema.WheelItemsPicker.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 15.03.2026.
//

import Foundation

extension Schema {
    typealias WheelItemsPicker = VC.WheelItemsPicker
}

extension Schema.WheelItemsPicker: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .wheelItemsPicker(
            self,
            properties
        )
    }
}

extension Schema.WheelItemsPicker: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case items
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            value: container.decode(Schema.Variable.self, forKey: .value),
            items: container.decode([Schema.WheelItemsPicker.Item].self, forKey: .items)
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(items, forKey: .items)
    }
}

