//
//  Animation.BoxParameters.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.04.2025.
//

import Foundation

package extension AdaptyViewConfiguration.Animation {
    struct BoxParameters: Sendable, Hashable {
        package let width: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Unit>?
        package let height: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Unit>?
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.BoxParameters {
    static func create(
        width: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Unit>? = nil,
        height: AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Unit>? = nil
    ) -> Self {
        .init(
            width: width,
            height: height
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.BoxParameters: Codable {
    enum CodingKeys: String, CodingKey {
        case width
        case height
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Unit>.self, forKey: .width)
        height = try container.decodeIfPresent(AdaptyViewConfiguration.Animation.Range<AdaptyViewConfiguration.Unit>.self, forKey: .height)

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
