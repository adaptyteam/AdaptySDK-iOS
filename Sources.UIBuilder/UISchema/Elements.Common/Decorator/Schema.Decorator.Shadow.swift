//
//  Schema.Decorator.Shadow.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//
//

import Foundation

extension Schema.Decorator.Shadow {
    static let `default` = (
        kind: Schema.Decorator.Shadow.Kind.drop,
        blurRadius: 0.0,
        offset: Schema.Offset.zero
    )
}

extension Schema.Decorator.Shadow: DecodableWithConfiguration {

    enum DecodingConfiguration {
        case defaultShadow
        case legacyDropShadow
        case legacyInnerShadow

    }

    enum CodingKeys: String, CodingKey {
        case id
        case kind = "type"
        case colorAssetId = "color"
        case blurRadius = "blur_radius"
        case offset
    }

    init(from decoder: Decoder, configuration: DecodingConfiguration) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shadowId: Int?
        let shadowKind: Schema.Decorator.Shadow.Kind

        switch configuration {
        case .defaultShadow:
            let id = try container.decodeIfPresent(Int.self, forKey: .id)
            if let id , id <= 0 {
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Shadow ID must be positive")
            }
            shadowId = id
            shadowKind = try container.decodeIfPresent(Schema.Decorator.Shadow.Kind.self, forKey: .kind)
            ?? Schema.Decorator.Shadow.default.kind
        case .legacyDropShadow:
            shadowId = 0
            shadowKind = .drop
        case .legacyInnerShadow:
            shadowId = 0
            shadowKind = .inner
        }

        try self.init(
            id: shadowId,
            kind: shadowKind,
            filling: container.decode(Schema.AssetReference.self, forKey: .colorAssetId),
            blurRadius: container.decodeIfPresent(Double.self, forKey: .blurRadius)
                ?? Schema.Decorator.Shadow.default.blurRadius,
            offset: container.decodeIfPresent(VC.Offset.self, forKey: .offset)
                ?? Schema.Decorator.Shadow.default.offset
        )
    }
}


