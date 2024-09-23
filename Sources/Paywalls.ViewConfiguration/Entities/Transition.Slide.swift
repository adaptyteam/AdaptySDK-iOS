//
//  Transition.Slide.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension AdaptyUI {
    package struct TransitionSlide: Sendable, Hashable {
        static let `default` = AdaptyUI.TransitionSlide(
            startDelay: 0.0,
            duration: 0.3,
            interpolator: AdaptyUI.Transition.Interpolator.default
        )

        package let startDelay: TimeInterval
        package let duration: TimeInterval
        package let interpolator: AdaptyUI.Transition.Interpolator
    }
}

#if DEBUG
    package extension AdaptyUI.TransitionSlide {
        static func create(
            startDelay: TimeInterval = `default`.startDelay,
            duration: TimeInterval = `default`.duration,
            interpolator: AdaptyUI.Transition.Interpolator = `default`.interpolator
        ) -> Self {
            .init(
                startDelay: startDelay,
                duration: duration,
                interpolator: interpolator
            )
        }
    }
#endif

extension AdaptyUI.TransitionSlide: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyUI.TransitionSlide.default.startDelay
        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? AdaptyUI.TransitionSlide.default.duration
        interpolator = try (container.decodeIfPresent(AdaptyUI.Transition.Interpolator.self, forKey: .interpolator)) ?? AdaptyUI.TransitionSlide.default.interpolator
    }
}
