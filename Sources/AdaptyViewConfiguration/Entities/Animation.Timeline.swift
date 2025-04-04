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
            repeatType: nil,
            repeatDelay: 0.0,
            repeatMaxCount: nil,
        )
        package let duration: TimeInterval
        package let interpolator: Interpolator
        package let startDelay: TimeInterval
        package let repeatType: RepeatType?
        package let repeatDelay: TimeInterval
        package let repeatMaxCount: Int?

        package enum RepeatType: String {
            case restart
            case reverse
        }
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.Timeline {
    static func create(
        startDelay: TimeInterval = Self.default.startDelay,
        duration: TimeInterval = Self.default.duration,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator = Self.default.interpolator,
        repeatType: RepeatType? = Self.default.repeatType,
        repeatDelay: TimeInterval = Self.default.repeatDelay,
        repeatMaxCount: Int? = Self.default.repeatMaxCount
    ) -> Self {
        .init(
            duration: duration,
            interpolator: interpolator,
            startDelay: startDelay,
            repeatType: repeatType,
            repeatDelay: repeatDelay,
            repeatMaxCount: repeatMaxCount
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.Timeline: Codable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case repeatType = "repeat"
        case repeatDelay = "repeat_delay"
        case repeatMaxCount = "repeat_max_count"
        case duration
        case interpolator

    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultValue = Self.default
        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? defaultValue.startDelay

        repeatType = try container.decodeIfPresent(RepeatType.self, forKey: .repeatType) ?? defaultValue.repeatType

        repeatDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .repeatDelay)).map { $0 / 1000.0 } ?? defaultValue.repeatDelay

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

        try container.encodeIfPresent(repeatType?.rawValue, forKey: .repeatType)

        if repeatDelay != defaultValue.repeatDelay {
            try container.encode(repeatDelay * 1000, forKey: .repeatDelay)
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

extension AdaptyViewConfiguration.Animation.Timeline.RepeatType: Codable {}
