//
//  VC.Transition.Slide.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension VC {
    struct TransitionSlide: Sendable, Hashable {
        static let `default` = VC.TransitionSlide(
            startDelay: 0.0,
            duration: 0.3,
            interpolator: VC.Animation.Interpolator.default
        )

        package let startDelay: TimeInterval
        package let duration: TimeInterval
        package let interpolator: VC.Animation.Interpolator
    }
}

#if DEBUG
package extension VC.TransitionSlide {
    static func create(
        startDelay: TimeInterval = `default`.startDelay,
        duration: TimeInterval = `default`.duration,
        interpolator: VC.Animation.Interpolator = `default`.interpolator
    ) -> Self {
        .init(
            startDelay: startDelay,
            duration: duration,
            interpolator: interpolator
        )
    }
}
#endif

extension VC.TransitionSlide: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case startDelay = "start_delay"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? VC.TransitionSlide.default.startDelay
        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? VC.TransitionSlide.default.duration
        interpolator = try (container.decodeIfPresent(VC.Animation.Interpolator.self, forKey: .interpolator)) ?? VC.TransitionSlide.default.interpolator
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
