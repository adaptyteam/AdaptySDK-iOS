//
//  Schema.Transition.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema {
    typealias Transition = VC.Transition
}

extension Schema.Transition {
    static let `default` = Self(
        startDelay: 0.0,
        duration: 0.3,
        interpolator: VC.Animation.Interpolator.default
    )
}

extension Schema.Transition: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case duration
        case interpolator
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(Double.self, forKey: .startDelay))
            .map { $0 / 1000.0 }
            ?? Self.default.startDelay
        duration = try (container.decodeIfPresent(Double.self, forKey: .duration))
            .map { $0 / 1000.0 }
            ?? Self.default.duration
        interpolator = try (container.decodeIfPresent(Schema.Animation.Interpolator.self, forKey: .interpolator)) ?? Self.default.interpolator
    }
}
