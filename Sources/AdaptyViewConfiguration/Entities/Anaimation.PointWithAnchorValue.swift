//
//  Animation.PointWithAnchorValue.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct PointWithAnchorValue: Sendable, Hashable {
        package let start: AdaptyViewConfiguration.Point
        package let end: AdaptyViewConfiguration.Point
        package let anchor: AdaptyViewConfiguration.Point
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.PointWithAnchorValue {
    static func create(
        start: AdaptyViewConfiguration.Point,
        end: AdaptyViewConfiguration.Point,
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

extension AdaptyViewConfiguration.Animation.PointWithAnchorValue: Codable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(AdaptyViewConfiguration.Point.self, forKey: .start)
        end = try container.decode(AdaptyViewConfiguration.Point.self, forKey: .end)
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
