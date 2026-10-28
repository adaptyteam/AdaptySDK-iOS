//
//  Schema.Decorator.Shadow.Kind.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 27.10.2026.
//

import Foundation
    
extension Schema.Decorator.Shadow.Kind: RawRepresentable {
    private enum Key {
        static let drop = "drop_shadow"
        static let inner = "inner_shadow"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.drop: self = .drop
        case Key.inner: self = .inner
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .drop: Key.drop
        case .inner: Key.inner
        }
    }
}

extension Schema.Decorator.Shadow.Kind: Codable {}
