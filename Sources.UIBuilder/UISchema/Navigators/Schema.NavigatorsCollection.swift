//
//  Schema.NavigatorsCollection.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 30.01.2026.
//

import Foundation

extension Schema {
    struct NavigatorsCollection: Sendable, Hashable {
        let values: [NavigatorIdentifier: Navigator]
    }
}

extension Schema.NavigatorsCollection: DecodableWithConfiguration {
    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        var nestedConfiguration = configuration

        var values = [String: Schema.Navigator]()
        values.reserveCapacity(container.allKeys.count)
        try container.allKeys.forEach { key in
            nestedConfiguration.insideNavigatorId = key.stringValue
            let value = try container.decode(Schema.Navigator.self, forKey: key, configuration: nestedConfiguration)
            values[value.id] = value
        }

        if !values.keys.contains(Schema.Navigator.default.id) {
            values.reserveCapacity(values.count + 1)
            values[Schema.Navigator.default.id] = Schema.Navigator.default
        }

        self.init(values: values)
    }
}
