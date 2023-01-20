//
//  ViewItem.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    enum ViewItem {
        case asset(String)
        case text(Text)
        case textRows(TextRows)
        case unknown(String?)
    }
}

extension AdaptyUI.ViewItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ContentType: String, Codable {
        case text
        case textRows = "text-rows"
    }

    public init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        if let assetId = try? single.decode(String.self) {
            self = .asset(assetId)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(nil)
            return
        }
        switch ContentType(rawValue: type) {
        case .text:
            self = .text(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Text.self))
//        case .textRows:
//            self = .textRows(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.TextRows.self))
        default:
            self = .unknown(type)
        }
    }
}
