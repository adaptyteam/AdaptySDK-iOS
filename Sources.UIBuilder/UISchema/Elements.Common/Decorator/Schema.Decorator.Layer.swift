//
//  Schema.Decorator.Layer.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.10.2026.
//

import Foundation

extension Schema.Decorator.Layer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case blend
        case effects
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decodeIfPresent(Int.self, forKey: .id)
        if let id, id <= 0 {
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Layer ID must be positive")
        }

        try self.init(
            id: id,
            kind: Schema.Decorator.Layer.Kind(from: decoder),
            blend: (try? container.decodeIfPresent(Schema.BlendMode.self, forKey: .blend)) ?? .default,
            effects: container.decodeEffects(forKey: .effects)
        )
    }
}

private enum EffectCodingKeys: String, CodingKey {
    case kind = "type"
}

private extension KeyedDecodingContainer {
    func decodeEffects(forKey key: Key) throws -> [Schema.Decorator.Shadow] {
        guard contains(key) else { return [] }
        if try decodeNil(forKey: key) { return [] }

        var array = try self.nestedUnkeyedContainer(forKey: key)

        var effects = [Schema.Decorator.Shadow]()
        if let count = array.count {
            effects.reserveCapacity(count)
        }
        while !array.isAtEnd {
            let decoder = try array.superDecoder()
            let effect = try decoder.container(keyedBy: EffectCodingKeys.self)
            if let kind = try effect.decodeIfPresent(String.self, forKey: .kind),
               Schema.Decorator.Shadow.Kind(rawValue: kind) == nil {
                continue
            }
            effects.append(try Schema.Decorator.Shadow(from: decoder, configuration: .defaultShadow))
        }
        return effects
    }
}
