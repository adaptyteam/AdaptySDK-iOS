//
//  Schema.Stack.Kind.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 01.12.2025.
//

import Foundation

extension Schema.Stack {
    typealias Kind = VC.Stack.Kind
}

extension Schema.Stack.Kind: RawRepresentable {
    private enum Key {
        static let vertical = "v_stack"
        static let horizontal = "h_stack"
        static let z = "z_stack"
    }
    
    package init?(rawValue value: String) {
        switch value {
        case Key.vertical: self = .vertical
        case Key.horizontal: self = .horizontal
        case Key.z: self = .z
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .vertical: Key.vertical
        case .horizontal: Key.horizontal
        case .z: Key.z
        }
    }
}

extension Schema.Stack.Kind: Decodable {}
