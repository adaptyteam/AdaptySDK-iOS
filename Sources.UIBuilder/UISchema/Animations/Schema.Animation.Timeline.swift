//
//  Schema.Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation {
    typealias Timeline = VC.Animation.Timeline
}

extension Schema.Animation.Timeline {
    static let `default` = Self(
        duration: 0.3,
        interpolator: .default,
        startDelay: 0.0,
        loop: nil,
        loopDelay: 0.0,
        pingPongDelay: 0.0,
        loopCount: nil
    )
}

extension Schema.Animation.Timeline: Codable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case loop
        case loopDelay = "loop_delay"
        case pingPongDelay = "ping_pong_delay"
        case loopCount = "loop_count"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultValue = Self.default
        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? defaultValue.startDelay

        loop = try container.decodeIfPresent(Loop.self, forKey: .loop) ?? defaultValue.loop

        loopDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .loopDelay)).map { $0 / 1000.0 } ?? defaultValue.loopDelay

        pingPongDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .pingPongDelay)).map { $0 / 1000.0 } ?? defaultValue.pingPongDelay

        loopCount = try container.decodeIfPresent(Int.self, forKey: .loopCount) ?? defaultValue.loopCount

        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? defaultValue.duration
        interpolator = try (container.decodeIfPresent(Schema.Animation.Interpolator.self, forKey: .interpolator)) ?? .default
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let defaultValue = Self.default

        if startDelay != defaultValue.startDelay {
            try container.encode(startDelay * 1000, forKey: .startDelay)
        }

        try container.encodeIfPresent(loop?.rawValue, forKey: .loop)

        if loopDelay != defaultValue.loopDelay {
            try container.encode(loopDelay * 1000, forKey: .loopDelay)
        }

        if pingPongDelay != defaultValue.pingPongDelay {
            try container.encode(pingPongDelay * 1000, forKey: .pingPongDelay)
        }

        try container.encodeIfPresent(loopCount, forKey: .loopCount)

        if duration != defaultValue.duration {
            try container.encode(duration * 1000, forKey: .duration)
        }

        if interpolator != defaultValue.interpolator {
            try container.encode(interpolator, forKey: .interpolator)
        }
    }
}
