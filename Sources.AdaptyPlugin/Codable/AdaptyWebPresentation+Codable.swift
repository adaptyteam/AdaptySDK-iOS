//
//  AdaptyWebPresentation+Codable.swift
//  AdaptyPlugin
//
//  Created by Aleksei Valiano on 24.11.2025.
//

import Adapty

extension AdaptyWebPresentation: Decodable {
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
}
