//
//  Schema.AutoSizeMode.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 23.04.2026.
//

import Foundation

extension Schema {
    typealias AutoSizeMode = VC.AutoSizeMode
}

extension Schema.AutoSizeMode {
    static let `default`: Self = .fill
}

extension Schema.AutoSizeMode: RawRepresentable {
    private enum Key {
        static let hug = "hug"
        static let fill = "fill"
        static let legacy = "legacy"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.hug: self = .hug
        case Key.fill: self = .fill
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .hug: Key.hug
        case .fill: Key.fill
        case .legacy: Key.legacy
        }
    }
}

extension Schema.AutoSizeMode: Codable {}

