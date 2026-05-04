//
//  Schema.LinearProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

import Foundation

extension Schema {
    typealias LinearProgress = VC.LinearProgress
}

extension Schema.LinearProgress: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .linearProgress(self, properties)
    }
}

extension Schema.LinearProgress: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case align
        case cornerRadius = "corner_radius"
        case assetId = "asset_id"
        case imageAspect = "image_aspect"
        case clip
        case value
        case duration
        case interpolator
        case actions = "action"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let orientation: Orientation =
            if try container.decode(String.self, forKey: .type) == Schema.Element.ContentType.horizontalProgress.rawValue {
                try .horizontal(container.decode(Schema.HorizontalAlignment.self, forKey: .align))
            } else {
                try .vertical(container.decode(Schema.VerticalAlignment.self, forKey: .align))
            }
        try self.init(
            orientation: orientation,
            cornerRadius: container.decodeIfPresent(Schema.CornerRadius.self, forKey: .cornerRadius) ?? .zero,
            asset: container.decode(Schema.AssetReference.self, forKey: .assetId),
            imageAspect: container.decodeIfPresent(Schema.AspectRatio.self, forKey: .imageAspect) ?? .default,
            clip: container.decodeIfPresent(Bool.self, forKey: .clip) ?? true,
            value: container.decode(Schema.Variable.self, forKey: .value),
            transition: .init(
                startDelay: 0,
                duration: container.decode(Double.self, forKey: .duration) / 1000.0,
                interpolator: container.decodeIfPresent(VC.Animation.Interpolator.self, forKey: .interpolator) ?? .default
            ),
            actions: container.decodeIfPresentActions(forKey: .actions) ?? []
        )
    }
}

