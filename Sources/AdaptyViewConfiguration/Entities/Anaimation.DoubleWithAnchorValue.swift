//
//  Animation.DoubleWithAnchorValue.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct DoubleWithAnchorValue: Sendable, Hashable {
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
        anchor: AdaptyViewConfiguration.Point = .center
    ) -> Self {
        .init(
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
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(Double.self, forKey: .start)
        end = try container.decode(Double.self, forKey: .end)
        anchor = try container.decodeIfPresent(AdaptyViewConfiguration.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
