//
//  Schema.ElementsCollection.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

extension Schema {
    struct ElementsCollection: Sendable, Hashable {
        let values: [String: Element]
    }
}

extension Schema.ElementsCollection: DecodableWithConfiguration {
    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var values = [String: Schema.Element]()
        values.reserveCapacity(container.allKeys.count)
        try container.allKeys.forEach { key in
            let value = try container.decode(Schema.Element.self, forKey: key, configuration: configuration)
            values[key.stringValue] = value
        }

        self.init(values: values)
    }
}
