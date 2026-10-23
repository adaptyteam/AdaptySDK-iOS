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
            effects: container.decodeIfPresent([Schema.Decorator.Shadow].self, forKey: .effects, configuration: .defaultShadow) ?? []
        )
    }
}

//private enum EffectCodingKeys: String, CodingKey {
//    case kind = "type"
//}
//
//private extension KeyedDecodingContainer {
//    func decodeEffects(forKey key: Key) throws -> [Schema.Decorator.Shadow] {
//
//
//
//        var array = try self.nestedUnkeyedContainer(forKey: key)
//
//        var effects = [Schema.Decorator.Shadow]()
//        if let count = array.count {
//            effects.reserveCapacity(count)
//        }
//        while !array.isAtEnd {
//            let effect = try array.nestedContainer(keyedBy: EffectCodingKeys.self)
//            do {
//                _ = try effect.decode(Schema.Decorator.Shadow.Kind.self, forKey: .kind)
//                effects.append(<#T##newElement: Schema.Decorator.Shadow##Schema.Decorator.Shadow#>)
//            } catch {
//                continue
//            }
//            try strings[item.decode(Schema.StringIdentifier.self, forKey: .id)] = try Item(
//                value: item.decode(Schema.RichText.self, forKey: .value),
//                fallback: item.decodeIfPresent(Schema.RichText.self, forKey: .fallback)
//            )
//        }
//        return effects
//    }
//}
