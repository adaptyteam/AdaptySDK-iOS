//
//  ButtonAction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//

import Foundation

extension AdaptyUI {
    public enum ButtonAction {
        case openUrl(String?)
        case restore
        case custom(String?)
        case close
    }
}

extension AdaptyUI.ButtonAction: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case url
        case customId = "custom_id"
    }

    enum Types: String {
        case openUrl = "open_url"
        case restore
        case custom
        case close
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try Types(rawValue: container.decode(String.self, forKey: .type)) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value"))
        case .openUrl:
            self = try .openUrl(container.decode(String.self, forKey: .url))
        case .restore:
            self = .restore
        case .close:
            self = .close
        case .custom:
            self = try .custom(container.decode(String.self, forKey: .customId))
        }
    }
}
