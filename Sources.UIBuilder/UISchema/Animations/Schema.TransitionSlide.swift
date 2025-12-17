//
//  Schema.TransitionSlide.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema {
    typealias TransitionSlide = VC.TransitionSlide
}

extension Schema.TransitionSlide {
    static let `default` = Self(
        startDelay: 0.0,
        duration: 0.3,
        interpolator: VC.Animation.Interpolator.default
    )
}

extension Schema.TransitionSlide: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case startDelay = "start_delay"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay))
            .map { $0 / 1000.0 }
            ?? Self.default.startDelay
        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration))
            .map { $0 / 1000.0 }
            ?? Self.default.duration
        interpolator = try (container.decodeIfPresent(Schema.Animation.Interpolator.self, forKey: .interpolator)) ?? Self.default.interpolator
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("slide", forKey: .type)

        if startDelay != Self.default.startDelay {
            try container.encode(startDelay * 1000, forKey: .startDelay)
        }

        if duration != Self.default.duration {
            try container.encode(duration * 1000, forKey: .duration)
        }

        if interpolator != Self.default.interpolator {
            try container.encode(interpolator, forKey: .interpolator)
        }
    }
}
