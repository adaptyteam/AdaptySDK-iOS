//
//  Schema.TemplatesCollection.swift
//  AdaptyUIBulder
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

extension Schema {
    struct TemplatesCollection: Sendable, Hashable {
        let values: [String: Template]
    }
}

extension Schema.TemplatesCollection: DecodableWithConfiguration {
    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        var nestedConfiguration = configuration
        nestedConfiguration.insideTemplate = true

        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var values = [String: Schema.Template]()
        values.reserveCapacity(container.allKeys.count)
        try container.allKeys.forEach { key in
            let value = try container.decode(Schema.Template.self, forKey: key, configuration: nestedConfiguration)

            let key = if key.stringValue.hasPrefix(Schema.Template.keyPrefix) {
                String(key.stringValue.dropFirst())
            } else {
                key.stringValue
            }

            values[key] = value
        }

        self.init(values: values)
    }
}
