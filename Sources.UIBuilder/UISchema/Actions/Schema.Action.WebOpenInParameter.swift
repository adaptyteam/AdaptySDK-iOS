//
//  Schema.Action.WebOpenInParameter.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 19.11.2025.
//

extension Schema.Action {
    typealias WebOpenInParameter = VC.Action.WebOpenInParameter
}

extension Schema.Action.WebOpenInParameter: RawRepresentable {
    private enum Key {
        static let browserOutApp = "browser_out_app"
        static let browserInApp = "browser_in_app"
    }

    package init?(rawValue value: String) {
        switch value {
        case Key.browserOutApp: self = .browserOutApp
        case Key.browserInApp: self = .browserInApp
        default: return nil
        }
    }

    package var rawValue: String {
        switch self {
        case .browserOutApp: Key.browserOutApp
        case .browserInApp: Key.browserInApp
        }
    }
}

extension Schema.Action.WebOpenInParameter: Codable {}
