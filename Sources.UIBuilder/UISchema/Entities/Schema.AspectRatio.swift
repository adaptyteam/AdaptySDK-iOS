//
//  Schema.AspectRatio.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 25.11.2025.
//

import Foundation

extension Schema {
    typealias AspectRatio = VC.AspectRatio
}

extension Schema.AspectRatio: RawRepresentable {
    private enum Key {
        static let fit = "fit"
        static let fill = "fill"
        static let stretch = "stretch"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.fit: self = .fit
        case Key.fill: self = .fill
        case Key.stretch: self = .stretch
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .fit: Key.fit
        case .fill: Key.fill
        case .stretch: Key.stretch
        }
    }
}

extension Schema.AspectRatio: Codable {}
