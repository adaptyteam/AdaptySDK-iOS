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

extension Schema.Pager.Animation: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case pageTransition = "page_transition"
        case repeatTransition = "repeat_transition"
        case afterInteractionDelay = "after_interaction_delay"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        try self.init(
            startDelay: (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay))
                .map { $0 / 1000.0 }
                ?? Self.default.startDelay,
            pageTransition: container.decodeIfPresent(Schema.Transition.self, forKey: .pageTransition)
                ?? .default,
            repeatTransition: container.decodeIfPresent(Schema.Transition.self, forKey: .repeatTransition),

            afterInteractionDelay: (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay))
                .map { $0 / 1000.0 }
                ?? Self.default.afterInteractionDelay
        )
    }
}
