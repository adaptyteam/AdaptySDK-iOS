//
//  ButtonAction.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 03.07.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

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
        switch Types(rawValue: try container.decode(String.self, forKey: .type)) {
        case .none:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "unknown value"))
        case .openUrl:
            self = .openUrl(try container.decode(String.self, forKey: .url))
        case .restore:
            self = .restore
        case .close:
            self = .close
        case .custom:
            self = .custom(try container.decode(String.self, forKey: .customId))
        }
    }
}
