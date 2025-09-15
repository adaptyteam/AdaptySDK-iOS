//
//  Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension AdaptyUIConfiguration.Animation {
    struct ScaleParameters: Sendable, Hashable {
        package let scale: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Point>
        package let anchor: AdaptyUIConfiguration.Point
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Animation.ScaleParameters {
    static func create(
        scale: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Point>,
        anchor: AdaptyUIConfiguration.Point = .center
    ) -> Self {
        .init(
            scale: scale,
            anchor: anchor
        )
    }
}
#endif

extension AdaptyUIConfiguration.Animation.ScaleParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case scale
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scale = try container.decode(AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Point>.self, forKey: .scale)
        anchor = try container.decodeIfPresent(AdaptyUIConfiguration.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
