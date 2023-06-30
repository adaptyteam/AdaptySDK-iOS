//
//  FooterBlock+Decodable.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 29.06.2023
//

import Foundation

extension AdaptyUI.FooterBlock.ButtonAction: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case url
    }

    enum Types: String {
        case openUrl = "open_url"
        case restore
        case custom
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
        case .custom:
            self = .custom
        }
    }
}

extension AdaptyUI.FooterBlock.Button: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case action
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        action = try container.decode(AdaptyUI.FooterBlock.ButtonAction.self, forKey: .action)
    }
}
