//
//  Animation.Range.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 04.04.2025.
//


import Foundation


package extension AdaptyViewConfiguration.Animation {
    struct Range<T>: Sendable, Hashable where T: Sendable, T: Hashable {
        package let start: T
        package let end: T
    }
}

#if DEBUG
package extension AdaptyViewConfiguration.Animation.Range {
    static func create(
        start: T,
        end: T
    ) -> Self {
        .init(
            start: start,
            end: end
        )
    }
}
#endif

extension AdaptyViewConfiguration.Animation.Range: Codable where T: Codable {
    enum CodingKeys: String, CodingKey {
        case start
        case end
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(T.self, forKey: .start)
        end = try container.decode(T.self, forKey: .end)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }
}
