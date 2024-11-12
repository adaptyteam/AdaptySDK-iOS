//
//  Transition.Slide.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension AdaptyUICore {
    package struct TransitionSlide: Sendable, Hashable {
        static let `default` = AdaptyUICore.TransitionSlide(
            startDelay: 0.0,
            duration: 0.3,
            interpolator: AdaptyUICore.Transition.Interpolator.default
        )

        package let startDelay: TimeInterval
        package let duration: TimeInterval
        package let interpolator: AdaptyUICore.Transition.Interpolator
    }
}

#if DEBUG
    package extension AdaptyUICore.TransitionSlide {
        static func create(
            startDelay: TimeInterval = `default`.startDelay,
            duration: TimeInterval = `default`.duration,
            interpolator: AdaptyUICore.Transition.Interpolator = `default`.interpolator
        ) -> Self {
            .init(
                startDelay: startDelay,
                duration: duration,
                interpolator: interpolator
            )
        }
    }
#endif

extension AdaptyUICore.TransitionSlide: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyUICore.TransitionSlide.default.startDelay
        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? AdaptyUICore.TransitionSlide.default.duration
        interpolator = try (container.decodeIfPresent(AdaptyUICore.Transition.Interpolator.self, forKey: .interpolator)) ?? AdaptyUICore.TransitionSlide.default.interpolator
    }
}
