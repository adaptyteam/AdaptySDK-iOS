//
//  Schema.TextProgress.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.04.2026.
//

extension Schema {
    struct TextProgress: Sendable {
        let format: Schema.RangeTextFormat
        let value: Variable
        let transition: Transition
        let actions: [Action]
    }
}

extension Schema.TextProgress: Schema.SimpleElement {
    @inlinable
    func buildElement(
        _ builder: Schema.ConfigurationBuilder,
        _ properties: VC.Element.Properties?
    ) -> VC.Element {
        try .textProgress(
            .init(
                format: builder.convertRangeTextFormat(format),
                value: value,
                transition: transition,
                actions: actions
            ),
            properties
        )
    }
}

extension Schema.TextProgress: Decodable {
    enum CodingKeys: String, CodingKey {
        case format
        case value
        case duration
        case interpolator
        case actions = "action"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            format: container.decodeRangeTextFormat(
                textAttributes: .init(from: decoder),
                forKey: .format
            ),
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

