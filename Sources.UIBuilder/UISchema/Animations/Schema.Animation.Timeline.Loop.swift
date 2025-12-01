//
//  Schema.Animation.Timeline.Loop.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema.Animation.Timeline.Loop: RawRepresentable {
    private enum Key {
        static let normal = "normal"
        static let pingPong = "ping_pong"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.normal: self = .normal
        case Key.pingPong: self = .pingPong
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .normal: Key.normal
        case .pingPong: Key.pingPong
        }
    }
}

extension Schema.Animation.Timeline.Loop: Codable {}
