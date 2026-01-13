//
//  Schema.Decorator.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    typealias Decorator = VC.Decorator
}

extension Schema.Decorator: Decodable {
    enum CodingKeys: String, CodingKey {
        case backgroundAssetId = "background"
        case rectangleCornerRadius = "rect_corner_radius"
        case borderAssetId = "border"
        case borderThickness = "thickness"
        case shapeType = "type"
        case shadow
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shape = (try? container.decode(Schema.ShapeType.self, forKey: .shapeType)) ?? .default

        let shapeType: Schema.ShapeType =
            if case .rectangle = shape,
            let rectangleCornerRadius = try container.decodeIfPresent(Schema.CornerRadius.self, forKey: .rectangleCornerRadius) {
                .rectangle(cornerRadius: rectangleCornerRadius)
            } else {
                shape
            }

        let border: Schema.Border? =
            if let assetReference = try container.decodeIfPresent(Schema.AssetReference.self, forKey: .borderAssetId) {
                try .init(
                    filling: assetReference,
                    thickness: container.decodeIfPresent(Double.self, forKey: .borderThickness) ?? Schema.Border.defaultThickness
                )
            } else {
                nil
            }

        try self.init(
            shapeType: shapeType,
            background: container.decodeIfPresent(Schema.AssetReference.self, forKey: .backgroundAssetId),
            border: border,
            shadow: container.decodeIfPresent(Schema.Shadow.self, forKey: .shadow)
        )
    }
}
