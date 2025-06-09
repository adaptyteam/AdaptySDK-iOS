//
//  Animation.Timeline.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct Timeline: Sendable, Hashable {
        static let `default` = Timeline(
            duration: 0.3,
            interpolator: .default,
            startDelay: 0.0,
            loop: nil,
            loopDelay: 0.0,
            pingPongDelay: 0.0,
            repeatMaxCount: nil,
        )
        package let duration: TimeInterval
        package let interpolator: Interpolator
        package let startDelay: TimeInterval
        package let loop: Loop?
        package let loopDelay: TimeInterval
        package let pingPongDelay: TimeInterval
        package let repeatMaxCount: Int?

        package enum Loop: String {
            case normal
            case pingPong = "ping_pong"
        }
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.Timeline {
    static func create(
        startDelay: TimeInterval = Self.default.startDelay,
        duration: TimeInterval = Self.default.duration,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator = Self.default.interpolator,
        loop: Loop? = Self.default.loop,
        loopDelay: TimeInterval = Self.default.loopDelay,
        pingPongDelay: TimeInterval = Self.default.pingPongDelay,
        repeatMaxCount: Int? = Self.default.repeatMaxCount
    ) -> Self {
        .init(
            duration: duration,
            interpolator: interpolator,
            startDelay: startDelay,
            loop: loop,
            loopDelay: loopDelay,
            pingPongDelay: pingPongDelay,
            repeatMaxCount: repeatMaxCount
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.Timeline: Codable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case loop
        case loopDelay = "loop_delay"
        case pingPongDelay = "ping_pong_delay"
        case repeatMaxCount = "repeat_max_count"
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

        repeatMaxCount = try container.decodeIfPresent(Int.self, forKey: .repeatMaxCount) ?? defaultValue.repeatMaxCount

        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? defaultValue.duration
        interpolator = try (container.decodeIfPresent(AdaptyViewConfiguration.Animation.Interpolator.self, forKey: .interpolator)) ?? .default
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

        try container.encodeIfPresent(repeatMaxCount, forKey: .repeatMaxCount)

        if duration != defaultValue.duration {
            try container.encode(duration * 1000, forKey: .duration)
        }

        if interpolator != defaultValue.interpolator {
            try container.encode(interpolator, forKey: .interpolator)
        }
    }
}

extension AdaptyViewConfiguration.Animation.Timeline.Loop: Codable {}
