//
//  Animation.Parameters.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct Parameters: Sendable, Hashable {
        static let `default` = Parameters(
            duration: 0.3,
            interpolator: .default,
            startDelay: 0.0,
            repiatType: nil,
            repiatDelay: 0.0,
            repiatNaxCount: nil
        )
        package let duration: TimeInterval
        package let interpolator: AdaptyViewConfiguration.Animation.Interpolator

        package let startDelay: TimeInterval
        package let repiatType: RepiatType?
        package let repiatDelay: TimeInterval
        package let repiatNaxCount: Int?

        package enum RepiatType: String {
            case restart
            case reverse
        }
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.Parameters {
    static func create(
        startDelay: TimeInterval = Self.default.startDelay,
        duration: TimeInterval = Self.default.duration,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator = Self.default.interpolator,
        repiatType: RepiatType? = Self.default.repiatType,
        repiatDelay: TimeInterval = Self.default.repiatDelay,
        repiatNaxCount: Int? = Self.default.repiatNaxCount
    ) -> Self {
        .init(
            duration: duration,
            interpolator: interpolator,
            startDelay: startDelay,
            repiatType: repiatType,
            repiatDelay: repiatDelay,
            repiatNaxCount: repiatNaxCount
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.Parameters: Codable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case repiatType = "repiat"
        case repiatDelay = "repiat_delay"
        case repiatNaxCount = "repiat_max_count"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let defaultValue = Self.default
        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? defaultValue.startDelay

        repiatType = try container.decodeIfPresent(RepiatType.self, forKey: .repiatType) ?? defaultValue.repiatType

        repiatDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .repiatDelay)).map { $0 / 1000.0 } ?? defaultValue.repiatDelay

        repiatNaxCount = try container.decodeIfPresent(Int.self, forKey: .repiatNaxCount) ?? defaultValue.repiatNaxCount

        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? defaultValue.duration
        interpolator = try (container.decodeIfPresent(AdaptyViewConfiguration.Animation.Interpolator.self, forKey: .interpolator)) ?? defaultValue.interpolator
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let defaultValue = Self.default

        if startDelay != defaultValue.startDelay {
            try container.encode(startDelay * 1000, forKey: .startDelay)
        }

        try container.encodeIfPresent(repiatType?.rawValue, forKey: .repiatType)

        if repiatDelay != defaultValue.repiatDelay {
            try container.encode(repiatDelay * 1000, forKey: .repiatDelay)
        }

        try container.encodeIfPresent(repiatNaxCount, forKey: .repiatNaxCount)

        if duration != defaultValue.duration {
            try container.encode(duration * 1000, forKey: .duration)
        }

        if interpolator != defaultValue.interpolator {
            try container.encode(interpolator, forKey: .interpolator)
        }
    }
}

extension AdaptyViewConfiguration.Animation.Parameters.RepiatType: Codable {}
