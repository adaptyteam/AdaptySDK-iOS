//
//  Schema.Text.OverflowMode.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema.Text.OverflowMode: RawRepresentable {
    private enum Key {
        static let scale = "scale"
        static let unknown = "unknown"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.scale: self = .scale
        case Key.unknown: self = .unknown
        default: self = .unknown
        }
    }

    package var rawValue: String {
        switch self {
        case .scale: Key.scale
        case .unknown: Key.unknown
        }
    }
}

extension Schema.Text.OverflowMode: Codable {}
