//
//  Transition.swift
//  AdaptyUI
//
//  Created by Aleksei Valiano on 16.01.2024
//

import Foundation

extension AdaptyUI {
    package enum Transition {
        case fade(TransitionFade)
        case unknown(String)

        package enum Interpolator {
            static let `default`: AdaptyUI.Transition.Interpolator = .easeInOut

            case easeInOut
            case easeIn
            case easeOut
            case linear
        }
    }

    package struct TransitionFade {
        static let defaultStartDelay: TimeInterval = 0.0
        static let defaultDuration: TimeInterval = 0.3
        static let defaultInterpolator = AdaptyUI.Transition.Interpolator.default

        package let startDelay: TimeInterval
        package let duration: TimeInterval
        package let interpolator: AdaptyUI.Transition.Interpolator
    }
}

#if DEBUG
    package extension AdaptyUI.TransitionFade {
        static func create(
            startDelay: TimeInterval = defaultStartDelay,
            duration: TimeInterval = defaultDuration,
            interpolator: AdaptyUI.Transition.Interpolator = defaultInterpolator
        ) -> Self {
            .init(
                startDelay: startDelay,
                duration: duration,
                interpolator: interpolator
            )
        }
    }
#endif

extension AdaptyUI.Transition: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum Types: String {
        case fade
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        switch Types(rawValue: typeName) {
        case .none:
            self = .unknown(typeName)
        case .fade:
            self = try .fade(AdaptyUI.TransitionFade(from: decoder))
        }
    }
}

extension AdaptyUI.Transition.Interpolator: Decodable {
    enum Values: String {
        case easeInOut = "ease_in_out"
        case easeIn = "ease_in"
        case easeOut = "ease_out"
        case linear
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch try Values(rawValue: container.decode(String.self)) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown value"))
        case .easeInOut:
            self = .easeInOut
        case .easeIn:
            self = .easeIn
        case .easeOut:
            self = .easeOut
        case .linear:
            self = .linear
        }
    }
}

extension AdaptyUI.TransitionFade: Decodable {
    enum CodingKeys: String, CodingKey {
        case startDelay = "start_delay"
        case duration
        case interpolator
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = try (container.decodeIfPresent(TimeInterval.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyUI.TransitionFade.defaultStartDelay
        duration = try (container.decodeIfPresent(TimeInterval.self, forKey: .duration)).map { $0 / 1000.0 } ?? AdaptyUI.TransitionFade.defaultDuration
        interpolator = try (container.decodeIfPresent(AdaptyUI.Transition.Interpolator.self, forKey: .interpolator)) ?? AdaptyUI.TransitionFade.defaultInterpolator
    }
}
