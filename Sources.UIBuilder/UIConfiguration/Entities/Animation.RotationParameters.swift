//
//  Animation.RotationParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension AdaptyUIConfiguration.Animation {
    struct RotationParameters: Sendable, Hashable {
        package let angle: AdaptyUIConfiguration.Animation.Range<Double>
        package let anchor: AdaptyUIConfiguration.Point
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Animation.RotationParameters {
    static func create(
        angle: AdaptyUIConfiguration.Animation.Range<Double>,
        anchor: AdaptyUIConfiguration.Point = .center
    ) -> Self {
        .init(
            angle: angle,
            anchor: anchor
        )
    }
}
#endif

extension AdaptyUIConfiguration.Animation.RotationParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case angle
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        angle = try container.decode(AdaptyUIConfiguration.Animation.Range<Double>.self, forKey: .angle)
        anchor = try container.decodeIfPresent(AdaptyUIConfiguration.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(angle, forKey: .angle)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
