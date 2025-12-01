//
//  Schema.HorizontalAlignment.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema {
    typealias HorizontalAlignment = VC.HorizontalAlignment
}

extension Schema.HorizontalAlignment: RawRepresentable {
    private enum Key {
        static let leading = "leading"
        static let trailing = "trailing"
        static let left = "left"
        static let center = "center"
        static let right = "right"
        static let justified = "justified"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.leading: self = .leading
        case Key.trailing: self = .trailing
        case Key.left: self = .left
        case Key.center: self = .center
        case Key.right: self = .right
        case Key.justified: self = .justified
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .leading: Key.leading
        case .trailing: Key.trailing
        case .left: Key.left
        case .center: Key.center
        case .right: Key.right
        case .justified: Key.justified
        }
    }
}

extension Schema.HorizontalAlignment: Codable {}
