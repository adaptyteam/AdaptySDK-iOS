//
//  VC.Animation.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2025.
//

import Foundation

extension AdaptyViewSource {
    typealias Unit = AdaptyViewConfiguration.Unit
    typealias Offset = AdaptyViewConfiguration.Offset
    enum Animation: Sendable {
        typealias Range = AdaptyViewConfiguration.Animation.Range
        typealias Timeline = AdaptyViewConfiguration.Animation.Timeline
        typealias RotationParameters = AdaptyViewConfiguration.Animation.RotationParameters
        typealias ScaleParameters = AdaptyViewConfiguration.Animation.ScaleParameters
        typealias BoxParameters = AdaptyViewConfiguration.Animation.BoxParameters

        case opacity(Timeline, Animation.Range<Double>)
        case offset(Timeline, Animation.Range<Offset>)
        case rotation(Timeline, Animation.RotationParameters)
        case scale(Timeline, ScaleParameters)
        case box(Timeline, BoxParameters)
        case background(Timeline, Animation.Range<String>)
        case border(Timeline, BorderParameters)
        case shadow(Timeline, ShadowParameters)
    }
}

extension AdaptyViewSource.Localizer {
    func animation(_ from: AdaptyViewSource.Animation) throws -> AdaptyViewConfiguration.Animation {
        switch from {
        case let .opacity(timeline, value):
            .opacity(timeline, value)
        case let .offset(timeline, value):
            .offset(timeline, value)
        case let .rotation(timeline, value):
            .rotation(timeline, value)
        case let .scale(timeline, value):
            .scale(timeline, value)
        case let .box(timeline, value):
            .box(timeline, value)
        case let .background(timeline, value):
            try .background(timeline, animationFillingValue(value))
        case let .border(timeline, value):
            try .border(timeline, animationBorderParameters(value))
        case let .shadow(timeline, value):
            try .shadow(timeline, animationShadowParameters(value))
        }
    }

    func animationFillingValue(_ from: AdaptyViewSource.Animation.Range<String>) throws -> AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Mode<AdaptyViewConfiguration.Filling>> {
        try .init(
            start: filling(from.start),
            end: filling(from.end)
        )
    }
}

extension AdaptyViewSource.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case interpolator

        case opacity
        case offset
        case angle
        case anchor
        case color
    }

    enum Types: String {
        case fade
        case opacity
        case offset
        case rotation
        case scale
        case box
        case background
        case border
        case shadow
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        switch Types(rawValue: typeName) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown animation type with name \(typeName)'"))
        case .fade:
            self = try .opacity(.init(from: decoder), .init(start: 0.0, end: 1.0))
        case .opacity:
            self = try .opacity(
                .init(from: decoder),
                container.decodeIfPresent(AdaptyViewSource.Animation.Range<Double>.self, forKey: .opacity)
                    ?? .init(start: 0.0, end: 1.0)
            )
        case .offset:
            self = try .offset(
                .init(from: decoder),
                container.decode(AdaptyViewSource.Animation.Range<AdaptyViewSource.Offset>.self, forKey: .offset)
            )
        case .rotation:
            self = try .rotation(
                .init(from: decoder),
                .init(from: decoder)
            )
        case .scale:
            self = try .scale(.init(from: decoder), .init(from: decoder))
        case .box:
            self = try .box(.init(from: decoder), .init(from: decoder))
        case .background:
            self = try .background(
                .init(from: decoder),
                container.decode(AdaptyViewSource.Animation.Range<String>.self, forKey: .color)
            )
        case .border:
            self = try .border(.init(from: decoder), .init(from: decoder))
        case .shadow:
            self = try .shadow(.init(from: decoder), .init(from: decoder))
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .opacity(timeline, value):
            try container.encode(Types.opacity.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .offset(timeline, value):
            try container.encode(Types.offset.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .rotation(timeline, value):
            try container.encode(Types.rotation.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .scale(timeline, value):
            try container.encode(Types.scale.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .box(timeline, value):
            try container.encode(Types.box.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .background(timeline, value):
            try container.encode(Types.background.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .border(timeline, value):
            try container.encode(Types.border.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .shadow(timeline, value):
            try container.encode(Types.shadow.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        }
    }
}
