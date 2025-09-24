//
//  VC.Animation.RotationParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension VC.Animation {
    struct RotationParameters: Sendable, Hashable {
        package let angle: VC.Animation.Range<Double>
        package let anchor: VC.Point
    }
}

#if DEBUG
package extension VC.Animation.RotationParameters {
    static func create(
        angle: VC.Animation.Range<Double>,
        anchor: VC.Point = .center
    ) -> Self {
        .init(
            angle: angle,
            anchor: anchor
        )
    }
}
#endif

extension VC.Animation.RotationParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case angle
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        angle = try container.decode(VC.Animation.Range<Double>.self, forKey: .angle)
        anchor = try container.decodeIfPresent(VC.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(angle, forKey: .angle)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
