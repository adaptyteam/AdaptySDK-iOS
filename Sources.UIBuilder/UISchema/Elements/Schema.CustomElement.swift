//
//  Schema.CustomElement.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.08.2026.
//

import Foundation

extension Schema {
    typealias CustomElement = VC.CustomElement
}

extension Schema.CustomElement: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .custom(self, properties)
    }
}

extension Schema.CustomElement: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "custom_id"
        case type = "custom_type"
        case assets
        case strings
        case bindings
        case payload
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(String.self, forKey: .id),
            type: container.decode(String.self, forKey: .type),
            assets: container.decodeIfPresent([String: Schema.AssetReference].self, forKey: .assets),
            strings: container.decodeIfPresent([String: Schema.StringReference].self, forKey: .strings),
            bindings: container.decodeIfPresent([String: Schema.Variable].self, forKey: .bindings),
            payload: container.decodeIfPresent(String.self, forKey: .payload)
        )
    }
}
