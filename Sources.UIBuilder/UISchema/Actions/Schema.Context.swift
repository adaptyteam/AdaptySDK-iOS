//
//  Schema.Context.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2026.
//

import Foundation

extension Schema {
    typealias Context = VC.Scope
}

extension Schema.Context {
    static let `default`: Self = .screen
}

extension Schema.Context: RawRepresentable {
    private enum Key {
        static let screen = "screen"
        static let global = "global"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.screen: self = .screen
        case Key.global: self = .global
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .screen: Key.screen
        case .global: Key.global
        }
    }
}

extension Schema.Context: Codable {}
