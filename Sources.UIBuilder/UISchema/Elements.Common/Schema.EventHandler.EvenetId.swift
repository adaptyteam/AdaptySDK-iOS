//
//  Schema.EventHandler.EvenetId.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

import Foundation

extension Schema.EventHandler.EventId: RawRepresentable {
    private enum Key {
        static let onWillAppiar = "on_will_appiar"
        static let onWillDisapper = "on_will_disappiar"
        static let onDidAppiar = "on_did_appiar"
        static let onDidDisapper = "on_did_disappiar"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.onWillAppiar: self = .onWillAppiar
        case Key.onWillDisapper: self = .onWillDisapper
        case Key.onDidAppiar: self = .onDidAppiar
        case Key.onDidDisapper: self = .onDidDisapper
        default: self = .custom(value)
        }
    }

    var rawValue: String {
        switch self {
        case .onWillAppiar: Key.onWillAppiar
        case .onWillDisapper: Key.onWillDisapper
        case .onDidAppiar: Key.onDidAppiar
        case .onDidDisapper: Key.onDidDisapper
        case let .custom(value): value
        }
    }
}

extension Schema.EventHandler.EventId: Codable {}

