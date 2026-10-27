//
//  Schema.Decorator.Layer.Kind.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.10.2026.
//

import Foundation

extension Schema.Decorator.Layer.Kind: Decodable {

    private enum Types {
        static let effects = "effects"
        static let image = "image"
        static let fill = "fill"
        static let stroke = "stroke"
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case thickness
        case aspect
        case assetId = "asset_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)

        switch type {
        case .none, Types.effects:
            self = .effects
        case Types.image:
            self = .image(
                asset: try container.decode(Schema.AssetReference.self, forKey: .assetId),
                aspect: try container.decodeIfPresent(Schema.AspectRatio.self, forKeys: .aspect) ?? .fill
            )
        case Types.fill:
            self = .fill(
                asset: try container.decode(Schema.AssetReference.self, forKey: .assetId)
            )
        case Types.stroke:
            self = .stroke(
                asset: try container.decode(Schema.AssetReference.self, forKey: .assetId),
                thickness: try container.decodeIfPresent(Double.self, forKey: .thickness) ?? 1.0
            )
        case .some(let type):
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown layer type: \(type)")
        }
    }
}
