//
//  Schema.EventHandler.Filter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

import Foundation

extension Schema.EventHandler.Filter: RawRepresentable {
    private enum Key {
        static let first = "first"
        static let notFirst = "not_first"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.first: self = .first
        case Key.notFirst: self = .notFirst
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .first: Key.first
        case .notFirst: Key.notFirst
        }
    }
}

extension Schema.EventHandler.Filter: Codable {}

