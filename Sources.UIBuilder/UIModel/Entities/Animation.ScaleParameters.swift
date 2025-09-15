//
//  Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct ScaleParameters: Sendable, Hashable {
        package let scale: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Point>
        package let anchor: AdaptyViewConfiguration.Point
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.ScaleParameters {
    static func create(
        scale: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Point>,
        anchor: AdaptyViewConfiguration.Point = .center
    ) -> Self {
        .init(
            scale: scale,
            anchor: anchor
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.ScaleParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case scale
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scale = try container.decode(AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Point>.self, forKey: .scale)
        anchor = try container.decodeIfPresent(AdaptyViewConfiguration.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
