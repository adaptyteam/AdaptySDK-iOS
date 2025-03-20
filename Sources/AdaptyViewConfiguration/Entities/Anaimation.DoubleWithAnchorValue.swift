//
//  Animation.DoubleWithAnchorValue.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct DoubleWithAnchorValue: Sendable, Hashable {
        package let interpolator: AdaptyViewConfiguration.Animation.Interpolator
        package let start: Double
        package let end: Double
        package let anchor: AdaptyViewConfiguration.Point
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.DoubleWithAnchorValue {
    static func create(
        start: Double,
        end: Double,
        anchor: AdaptyViewConfiguration.Point = .center,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator = .default
    ) -> Self {
        .init(
            interpolator: interpolator,
            start: start,
            end: end,
            anchor: anchor
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.DoubleWithAnchorValue: Codable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case anchor
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(Double.self, forKey: .start)
        end = try container.decode(Double.self, forKey: .end)
        anchor = try container.decodeIfPresent(AdaptyViewConfiguration.Point.self, forKey: .anchor) ?? .center
        interpolator = try (container.decodeIfPresent(AdaptyViewConfiguration.Animation.Interpolator.self, forKey: .interpolator)) ?? .default
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
        if interpolator != .default {
            try container.encode(interpolator, forKey: .interpolator)
        }
    }
}
