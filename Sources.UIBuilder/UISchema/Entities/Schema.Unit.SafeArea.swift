//
//  Schema.Unit.SafeArea.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema.Unit.SafeArea: RawRepresentable {
    private enum Key {
        static let start = "start"
        static let end = "end"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.start: self = .start
        case Key.end: self = .end
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .start: Key.start
        case .end: Key.end
        }
    }
}

extension Schema.Unit.SafeArea: Codable {}
