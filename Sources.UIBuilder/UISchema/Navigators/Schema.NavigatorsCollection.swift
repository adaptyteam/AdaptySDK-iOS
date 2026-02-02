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

        init(values: [Schema.NavigatorIdentifier: Schema.Navigator]? = nil) {
            var values = values ?? [:]
            if !values.keys.contains(Schema.Navigator.default.id) {
                values.reserveCapacity(values.count + 1)
                values[Schema.Navigator.default.id] = Schema.Navigator.default
            }

            self.values = values
        }
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

        self.init(values: values)
    }
}

extension Schema.NavigatorsCollection {
    init(data: [String: String]?, from decoder: JSONDecoder, configuration: Schema.DecodingConfiguration) throws {
        guard let data, !data.isEmpty else {
            self.init()
            return
        }

        let array = try data.compactMapValues {
            $0.data(using: .utf8)
        }.map { id, data in
            var nestedConfiguration = configuration
            nestedConfiguration.insideNavigatorId = id
            let navigator = try decoder.decode(Schema.Navigator.self, from: data, with: nestedConfiguration)
            return (id, navigator)
        }

        self.init(values: Dictionary(array) { first, _ in first })
    }
}
