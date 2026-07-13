//
//  Schema.EventHandler.EventId.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 06.04.2026.
//

import Foundation

extension Schema.EventHandler.EventId: RawRepresentable {
    private enum Key {
        static let onWillAppear = "on_will_appear"
        static let onWillDisappear = "on_will_disappear"
        static let onDidAppear = "on_did_appear"
        static let onDidDisappear = "on_did_disappear"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.onWillAppear: self = .onWillAppear
        case Key.onWillDisappear: self = .onWillDisappear
        case Key.onDidAppear: self = .onDidAppear
        case Key.onDidDisappear: self = .onDidDisappear
        default: self = .custom(value)
        }
    }

    var rawValue: String {
        switch self {
        case .onWillAppear: Key.onWillAppear
        case .onWillDisappear: Key.onWillDisappear
        case .onDidAppear: Key.onDidAppear
        case .onDidDisappear: Key.onDidDisappear
        case let .custom(value): value
        }
    }
}

extension Schema.EventHandler.EventId: Codable {}
