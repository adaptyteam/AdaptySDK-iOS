//
//  Schema.VerticalAlignment.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias VerticalAlignment = VC.VerticalAlignment
}

extension Schema.VerticalAlignment: RawRepresentable {
    private enum Key {
        static let top = "top"
        static let center = "center"
        static let bottom = "bottom"
        static let justified = "justified"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.top: self = .top
        case Key.center: self = .center
        case Key.bottom: self = .bottom
        case Key.justified: self = .justified
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .top: Key.top
        case .center: Key.center
        case .bottom: Key.bottom
        case .justified: Key.justified
        }
    }
}

extension Schema.VerticalAlignment: Codable {}
