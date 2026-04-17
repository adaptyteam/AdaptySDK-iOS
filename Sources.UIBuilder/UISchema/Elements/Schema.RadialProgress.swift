//
//  Schema.RadialProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

extension Schema {
    typealias RadialProgress = VC.RadialProgress
}

extension Schema.RadialProgress: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .radialProgress(self, properties)
    }
}

extension Schema.RadialProgress: Decodable {
    enum CodingKeys: String, CodingKey {
        case thickness
        case sweepAngle = "sweep_angle"
        case startAngle = "start_angle"
        case clockwise
        case assetId = "asset_id"
        case clip
        case value
        case duration
        case interpolator
        case actions = "action"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            thickness: container.decodeIfPresent(Double.self, forKey: .thickness),
            sweepAngle: container.decodeIfPresent(Double.self, forKey: .sweepAngle) ?? 360,
            startAngle: container.decodeIfPresent(Double.self, forKey: .clockwise) ?? -90,
            clockwise: container.decodeIfPresent(Bool.self, forKey: .clockwise) ?? true,
            asset: container.decode(Schema.AssetReference.self, forKey: .assetId),
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

