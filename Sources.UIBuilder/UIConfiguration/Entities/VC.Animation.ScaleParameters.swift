//
//  VC.Animation.ScaleParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 20.03.2025
//

import Foundation

package extension VC.Animation {
    struct ScaleParameters: Sendable, Hashable {
        package let scale: VC.Animation.Range<VC.Point>
        package let anchor: VC.Point
    }
}

#if DEBUG
package extension VC.Animation.ScaleParameters {
    static func create(
        scale: VC.Animation.Range<VC.Point>,
        anchor: VC.Point = .center
    ) -> Self {
        .init(
            scale: scale,
            anchor: anchor
        )
    }
}
#endif

extension VC.Animation.ScaleParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case scale
        case anchor
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scale = try container.decode(VC.Animation.Range<VC.Point>.self, forKey: .scale)
        anchor = try container.decodeIfPresent(VC.Point.self, forKey: .anchor) ?? .center
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scale, forKey: .scale)
        if anchor != .center {
            try container.encode(anchor, forKey: .anchor)
        }
    }
}
