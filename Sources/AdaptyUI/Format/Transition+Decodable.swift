//
//  Transition+Decodable.swift
//
//
//  Created by Aleksei Valiano on 16.01.2024
//
//

import Foundation

extension AdaptyUI {
    struct TransitionUnion: Decodable {
        let type: String
        let items: [AdaptyUI.Transition]
    }
}

extension AdaptyUI.Transition: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum Types: String {
        case fade
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .type)
        switch Types(rawValue: typeName) {
        case .none:
            self = .unknown(typeName)
        case .fade:
            self = .fade(try AdaptyUI.TransitionFade(from: decoder))
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        switch Values(rawValue: try container.decode(String.self)) {
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        startDelay = (try container.decodeIfPresent(Double.self, forKey: .startDelay)).map { $0 / 1000.0 } ?? AdaptyUI.TransitionFade.defaultStartDelay
        duration = (try container.decodeIfPresent(Double.self, forKey: .duration)).map { $0 / 1000.0 } ?? AdaptyUI.TransitionFade.defaultDuration
        interpolator = (try container.decodeIfPresent(AdaptyUI.Transition.Interpolator.self, forKey: .interpolator)) ?? AdaptyUI.TransitionFade.defaultInterpolator
    }
}
