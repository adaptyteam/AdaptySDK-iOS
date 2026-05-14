//
//  AdaptyWebPresentation+Codable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 24.11.2025.
//

import Adapty

extension AdaptyWebPresentation: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        switch stringValue {
        case "browser_out_app":
            self = .externalBrowser
        case "browser_in_app":
            self = .inAppBrowser
        default:
            self = .externalBrowser
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .externalBrowser:
            try container.encode("browser_out_app")
        case .inAppBrowser:
            try container.encode("browser_in_app")
        }
    }
}
