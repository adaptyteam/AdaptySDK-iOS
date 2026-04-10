//
//  Schema.Section.Animation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksey Goncharov on 10.04.2026.
//

import Foundation

extension Schema.Section {
    typealias Animation = VC.Section.Animation
}

extension Schema.Section.Animation {
    static let `default` = (
        interpolator: Schema.Animation.Interpolator.easeInOut,
        duration: 0.2
    )
}

extension Schema.Section.Animation: Codable {
    enum CodingKeys: String, CodingKey {
        case interpolator
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        interpolator = try container.decodeIfPresent(
            VC.Animation.Interpolator.self,
            forKey: .interpolator
        ) ?? Self.default.interpolator

        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration))
            .map { $0 / 1000.0 }
            ?? Self.default.duration
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if interpolator != .default {
            try container.encode(interpolator, forKey: .interpolator)
        }

        if duration != 0.3 {
            try container.encode(duration * 1000, forKey: .duration)
        }
    }
}
