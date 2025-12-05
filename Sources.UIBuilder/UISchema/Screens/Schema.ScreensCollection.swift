//
//  Schema.ScreensCollection.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 05.12.2025.
//

import Foundation

extension Schema {
    struct ScreensCollection: Sendable, Hashable {
        let values: [String: Screen]
    }
}

extension Schema.ScreensCollection {
    static let defaultScreenKey = "default"

    var defaultScreen: Schema.Screen? {
        values[Self.defaultScreenKey]
    }
}

extension Schema.ScreensCollection: DecodableWithConfiguration {
    init(from decoder: any Decoder, configuration: Schema.DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var values = [String: Schema.Screen]()
        values.reserveCapacity(container.allKeys.count)
        try container.allKeys.forEach { key in
            let value = try container.decode(Schema.Screen.self, forKey: key, configuration: configuration)
            values[key.stringValue] = value
        }

        self.init(values: values)
    }
}
