//
//  Schema.Context.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.01.2026.
//

import Foundation

extension Schema {
    typealias Context = VC.Context
}

extension Schema.Context {
    static let `default`: Self = .window
}

extension Schema.Context: RawRepresentable {
    private enum Key {
        static let window = "window"
        static let global = "global"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.window: self = .window
        case Key.global: self = .global
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .window: Key.window
        case .global: Key.global
        }
    }
}

extension Schema.Context: Codable {}
