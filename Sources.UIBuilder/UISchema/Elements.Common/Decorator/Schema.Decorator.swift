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
        case shapeType = "type"
        case rectangleCornerRadius = "rect_corner_radius"
        case overlays
        case underlays
        case blurRadius = "blur_radius"
        case clip

        case legacyBackgroundAssetId = "background"
        case legacyBorderAssetId = "border"
        case legacyBorderThickness = "thickness"
        case legacyShadow = "shadow"
        case legacyInnerShadow = "inner_shadow"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let shape = (try? container.decode(Schema.ShapeType.self, forKey: .shapeType)) ?? .default

        let shapeType: Schema.ShapeType =
            if case .rectangle = shape,
            let rectangleCornerRadius = try container.decodeIfPresent(Schema.CornerRadius.self, forKey: .rectangleCornerRadius) {
                .rectangle(cornerRadius: rectangleCornerRadius)
            } else {
                shape
            }


        var legacyOverlays: [Schema.Decorator.Layer] = []
        var legacyUnderlays: [Schema.Decorator.Layer] = []

        if let legacyBackgroundAssetId = try container.decodeIfPresent(Schema.AssetReference.self, forKey: .legacyBackgroundAssetId) {

            var shadows = [Schema.Decorator.Shadow]()

            if let dropShadow = try container.decodeIfPresent(Schema.Decorator.Shadow.self, forKey: .legacyShadow, configuration: .legacyDropShadow) {
                shadows = [dropShadow]
            }
            if let innerShadow = try container.decodeIfPresent(Schema.Decorator.Shadow.self, forKey: .legacyInnerShadow, configuration: .legacyInnerShadow) {
                shadows += [innerShadow]
            }

            legacyUnderlays = [.init(
                id: 0,
                kind: .image(asset: legacyBackgroundAssetId, aspect: .fill),
                blend: .default,
                effects: shadows
            )]

        } else if let legacyShadow = try container.decodeIfPresent(Schema.Decorator.Shadow.self, forKey: .legacyShadow, configuration: .legacyDropShadow) {

            legacyUnderlays = [.init(
                id: 0,
                kind: .effects,
                blend: .default,
                effects: [legacyShadow]
            )]
        }

        if let legacyBorderAssetId = try container.decodeIfPresent(Schema.AssetReference.self, forKey: .legacyBorderAssetId) {
            let thickness = try container.decodeIfPresent(Double.self, forKey: .legacyBorderThickness) ?? 1.0

            legacyOverlays = [.init(
                id: 0,
                kind: .stroke(asset: legacyBorderAssetId, thickness: thickness),
                blend: .default,
                effects: []
            )]
        }

        let underlays = try container.decodeIfPresent([Schema.Decorator.Layer].self, forKey: .underlays) ?? []
        let overlays = try container.decodeIfPresent([Schema.Decorator.Layer].self, forKey: .overlays) ?? []

        try self.init(
            shapeType: shapeType,
            overlays: legacyOverlays + overlays,
            underlays: legacyUnderlays + underlays,
            blurRadius: container.decodeIfPresent(Double.self, forKey: .blurRadius),
            clip: container.decodeIfPresent(Clip.self, forKey: .clip) ?? .content
        )
    }
}
