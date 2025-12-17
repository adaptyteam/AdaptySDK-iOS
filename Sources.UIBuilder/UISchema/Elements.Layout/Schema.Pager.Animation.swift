//
//  Schema.Pager.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Pager {
    typealias Animation = VC.Pager.Animation
}

extension Schema.Pager.Animation {
    static let `default` = (
        startDelay: 0.0,
        afterInteractionDelay: 3.0
    )
}

extension Schema.Pager.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case pageTransition = "page_transition"
        case repeatTransition = "repeat_transition"
        case afterInteractionDelay = "after_interaction_delay"
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            startDelay: (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay))
                .map { $0 / 1000.0 }
                ?? Self.default.startDelay,
            pageTransition: container.decodeIfPresent(Schema.TransitionSlide.self, forKey: .pageTransition)
                ?? .default,
            repeatTransition: container.decodeIfPresent(Schema.TransitionSlide.self, forKey: .repeatTransition),

            afterInteractionDelay: (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay))
                .map { $0 / 1000.0 }
                ?? Self.default.afterInteractionDelay
        )
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if startDelay != Self.default.startDelay {
            try container.encode(startDelay * 1000, forKey: .startDelay)
        }
        try container.encode(pageTransition, forKey: .pageTransition)
        try container.encodeIfPresent(repeatTransition, forKey: .repeatTransition)
        if afterInteractionDelay != Self.default.afterInteractionDelay {
            try container.encode(afterInteractionDelay * 1000, forKey: .afterInteractionDelay)
        }
    }
}
