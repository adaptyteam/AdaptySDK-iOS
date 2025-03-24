//
//  VC.Animation.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2025.
//

import Foundation

extension AdaptyViewSource {
    enum Animation: Sendable {
        typealias Timeline = AdaptyViewConfiguration.Animation.Timeline
        typealias DoubleValue = AdaptyViewConfiguration.Animation.DoubleValue
        typealias UnitValue = AdaptyViewConfiguration.Animation.UnitValue
        typealias OffsetValue = AdaptyViewConfiguration.Animation.OffsetValue
        typealias DoubleWithAnchorValue = AdaptyViewConfiguration.Animation.DoubleWithAnchorValue
        typealias PointWithAnchorValue = AdaptyViewConfiguration.Animation.PointWithAnchorValue

        case opacity(Timeline, DoubleValue)
        case offset(Timeline, OffsetValue)
        case rotation(Timeline, DoubleWithAnchorValue)
        case scale(Timeline, PointWithAnchorValue)
        case width(Timeline, UnitValue)
        case height(Timeline, UnitValue)
        case background(Timeline, AssetIdValue)
        case border(Timeline, AssetIdValue)
        case borderThickness(Timeline, DoubleValue)
        case shadow(Timeline, AssetIdValue)
        case shadowOffset(Timeline, OffsetValue)
        case shadowBlurRadius(Timeline, DoubleValue)
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
        case let .width(timeline, value):
            .width(timeline, value)
        case let .height(timeline, value):
            .height(timeline, value)
        case let .background(timeline, value):
            try .background(timeline, animationFillingValue(value))
        case let .border(timeline, value):
            try .border(timeline, animationFillingValue(value))
        case let .borderThickness(timeline, value):
            .borderThickness(timeline, value)
        case let .shadow(timeline, value):
            try .shadow(timeline, animationFillingValue(value))
        case let .shadowOffset(timeline, value):
            try .shadowOffset(timeline, value)
        case let .shadowBlurRadius(timeline, value):
            try .shadowBlurRadius(timeline, value)
        }
    }
}

extension AdaptyViewSource.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case interpolator
    }

    enum Types: String {
        case fade
        case opacity
        case offset
        case rotation
        case scale
        case width
        case height
        case background
        case border
        case borderThickness = "border_thickness"
        case shadow
        case shadowOffset = "shadow_offset"
        case shadowBlurRadius = "shadow_blur_radius"

    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        switch Types(rawValue: typeName) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown animation type with name \(typeName)'"))
        case .fade:
            self = try .opacity(.init(from: decoder), .init(
                interpolator: (container.decodeIfPresent(AdaptyViewConfiguration.Animation.Interpolator.self, forKey: .interpolator)) ?? .default,
                start: 0.0,
                end: 1.0
            ))
        case .opacity:
            self = try .opacity(.init(from: decoder), .init(from: decoder))
        case .offset:
            self = try .offset(.init(from: decoder), .init(from: decoder))
        case .rotation:
            self = try .rotation(.init(from: decoder), .init(from: decoder))
        case .scale:
            self = try .scale(.init(from: decoder), .init(from: decoder))
        case .width:
            self = try .width(.init(from: decoder), .init(from: decoder))
        case .height:
            self = try .height(.init(from: decoder), .init(from: decoder))
        case .background:
            self = try .background(.init(from: decoder), .init(from: decoder))
        case .border:
            self = try .border(.init(from: decoder), .init(from: decoder))
        case .borderThickness:
            self = try .borderThickness(.init(from: decoder), .init(from: decoder))
        case .shadow:
            self = try .shadow(.init(from: decoder), .init(from: decoder))
        case .shadowOffset:
            self = try .shadowOffset(.init(from: decoder), .init(from: decoder))
        case .shadowBlurRadius:
            self = try .shadowBlurRadius(.init(from: decoder), .init(from: decoder))
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
        case let .width(timeline, value):
            try container.encode(Types.width.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .height(timeline, value):
            try container.encode(Types.height.rawValue, forKey: .type)
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
        case let .borderThickness(timeline, value):
            try container.encode(Types.borderThickness.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .shadow(timeline, value):
            try container.encode(Types.shadow.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .shadowOffset(timeline, value):
            try container.encode(Types.shadowOffset.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        case let .shadowBlurRadius(timeline, value):
            try container.encode(Types.shadowBlurRadius.rawValue, forKey: .type)
            try value.encode(to: encoder)
            try timeline.encode(to: encoder)
        }
    }
}
