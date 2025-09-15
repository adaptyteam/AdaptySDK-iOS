//
//  Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension AdaptyUIConfiguration.Animation {
    struct BoxParameters: Sendable, Hashable {
        package let width: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Unit>?
        package let height: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Unit>?
    }
}

#if DEBUG
package extension AdaptyUIConfiguration.Animation.BoxParameters {
    static func create(
        width: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Unit>? = nil,
        height: AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Unit>? = nil
    ) -> Self {
        .init(
            width: width,
            height: height
        )
    }
}
#endif

extension AdaptyUIConfiguration.Animation.BoxParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Unit>.self, forKey: .width)
        height = try container.decodeIfPresent(AdaptyUIConfiguration.Animation.Range<AdaptyUIConfiguration.Unit>.self, forKey: .height)

        if width == nil && height == nil {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "The width and height parameters cannot be absent together."))
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
    }
}
