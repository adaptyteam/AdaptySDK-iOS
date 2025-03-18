//
//  Animation.UnitValue.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct UnitValue: Sendable, Hashable {
        package let interpolator: AdaptyViewConfiguration.Animation.Interpolator
        package let start: AdaptyViewConfiguration.Unit
        package let end: AdaptyViewConfiguration.Unit
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.UnitValue {
    static func create(
        start: AdaptyViewConfiguration.Unit,
        end: AdaptyViewConfiguration.Unit,
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

extension AdaptyViewConfiguration.Animation.UnitValue: Codable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(AdaptyViewConfiguration.Unit.self, forKey: .start)
        end = try container.decode(AdaptyViewConfiguration.Unit.self, forKey: .end)
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
