//
//  Schema.Orientation.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 04.06.2026.
//

import Foundation

extension Schema {
    typealias Orientation = VC.Orientation
}

extension Schema.Orientation: RawRepresentable {
    private enum Key {
        static let portrait = "portrait"
        static let landscape = "landscape"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.portrait: self = .portrait
        case Key.landscape: self = .landscape
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .portrait: Key.portrait
        case .landscape: Key.landscape
        }
    }
}

extension Schema.Orientation: Codable {}

