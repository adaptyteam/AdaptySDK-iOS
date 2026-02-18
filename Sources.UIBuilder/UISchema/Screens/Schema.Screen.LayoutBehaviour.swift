//
//  Schema.Screen.LayoutBehaviour.swift
//  Adapty
//
//  Created by Aleksei Valiano on 18.02.2026.
//

extension Schema.Screen {
    typealias LayoutBehaviour = VC.Screen.LayoutBehaviour
}

extension Schema.Screen.LayoutBehaviour: RawRepresentable {
    private enum Key {
        static let `default` = "default"
        static let flat = "flat"
        static let transparent = "transparent"
        static let hero = "hero"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.default: self = .default
        case Key.flat: self = .flat
        case Key.transparent: self = .transparent
        case Key.hero: self = .hero
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .default: Key.default
        case .flat: Key.flat
        case .transparent: Key.transparent
        case .hero: Key.hero
        }
    }
}

extension Schema.Screen.LayoutBehaviour: Codable {}
