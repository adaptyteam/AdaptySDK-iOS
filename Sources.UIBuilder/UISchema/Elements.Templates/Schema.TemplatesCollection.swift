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
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var nestedConfiguration = configuration

        var values = [String: Schema.Template]()
        values.reserveCapacity(container.allKeys.count)
        try container.allKeys.forEach { key in
            let templateId = if key.stringValue.hasPrefix(Schema.Template.keyPrefix) {
                String(key.stringValue.dropFirst())
            } else {
                key.stringValue
            }

            nestedConfiguration.insideTemplateId = templateId

            let value = try container.decode(Schema.Template.self, forKey: key, configuration: nestedConfiguration)

            values[templateId] = value
        }

        self.init(values: values)
    }
}
