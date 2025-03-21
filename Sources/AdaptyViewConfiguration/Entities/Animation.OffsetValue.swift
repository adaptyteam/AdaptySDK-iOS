//
//  Animation.OffsetValue.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 21.03.2025.
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct OffsetValue: Sendable, Hashable {
        package let interpolator: Interpolator
        package let start: AdaptyViewConfiguration.Offset
        package let end: AdaptyViewConfiguration.Offset
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.OffsetValue {
    static func create(
        start: AdaptyViewConfiguration.Offset,
        end: AdaptyViewConfiguration.Offset,
        interpolator: AdaptyViewConfiguration.Animation.Interpolator = .default
    ) -> Self {
        .init(
            interpolator: interpolator,
            start: start,
            end: end
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.OffsetValue: Codable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(AdaptyViewConfiguration.Offset.self, forKey: .start)
        end = try container.decode(AdaptyViewConfiguration.Offset.self, forKey: .end)
        interpolator = try (container.decodeIfPresent(AdaptyViewConfiguration.Animation.Interpolator.self, forKey: .interpolator)) ?? .default
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        if interpolator != .default {
            try container.encode(interpolator, forKey: .interpolator)
        }
    }
}
