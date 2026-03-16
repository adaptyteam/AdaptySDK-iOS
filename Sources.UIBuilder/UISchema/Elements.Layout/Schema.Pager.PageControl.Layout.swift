//
//  Schema.Pager.PageControl.Layout.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 26.11.2025.
//

import Foundation

extension Schema.Pager.PageControl.Layout: RawRepresentable {
    private enum Key {
        static let overlaid = "overlaid"
        static let stacked = "stacked"
    }

    init?(rawValue value: String) {
        switch value {
        case Key.overlaid: self = .overlaid
        case Key.stacked: self = .stacked
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .overlaid: Key.overlaid
        case .stacked: Key.stacked
        }
    }
}

extension Schema.Pager.PageControl.Layout: Codable {}
