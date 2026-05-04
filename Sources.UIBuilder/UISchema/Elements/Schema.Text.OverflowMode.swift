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

    init?(rawValue value: String) {
        switch value {
        case Key.scale: self = .scale
        case Key.unknown: self = .unknown
        default: self = .unknown
        }
    }

    var rawValue: String {
        switch self {
        case .scale: Key.scale
        case .unknown: Key.unknown
        }
    }
}

extension Schema.Text.OverflowMode: Codable {}

extension KeyedDecodingContainer {
    func decodeIfPresentTextOverflowMode(forKey key: Key) throws -> Set<Schema.Text.OverflowMode> {
        if let value = try? decode(Schema.Text.OverflowMode.self, forKey: key) {
            Set([value])
        } else {
            try Set(decodeIfPresent([Schema.Text.OverflowMode].self, forKey: key) ?? [])
        }
    }
}

