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

extension Schema.WheelItemsPicker: Decodable {
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
}

