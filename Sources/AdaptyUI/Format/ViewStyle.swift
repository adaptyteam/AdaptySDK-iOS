//
//  ViewStyle.swift
//  AdaptySDK
//
//  Created by Aleksei Valiano on 20.01.2023
//  Copyright © 2023 Adapty. All rights reserved.
//

import Foundation

extension AdaptyUI {
    struct ViewStyle {
        let items: [String: ViewItem]
    }

    enum ViewItem {
        case group([String: ViewItem])
        case asset(String)
        case shape(Shape)
        case button(Button)
        case text(Text)
        case textRows(TextRows)
        case unknown(String?)
    }
}

extension AdaptyUI.ViewStyle: Decodable {
    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        items = try single.decode([String: AdaptyUI.ViewItem].self)
    }
}

extension AdaptyUI.ViewItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ContentType: String, Codable {
        case group
        case text
        case shape
        case button
        case textRows = "text-rows"
    }

    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()
        if let assetId = try? single.decode(String.self) {
            self = .asset(assetId)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type) ?? ContentType.group.rawValue
        switch ContentType(rawValue: type) {
        case .shape:
            self = .shape(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Shape.self))
        case .button:
            self = .button(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Button.self))
        case .text:
            self = .text(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Text.self))
        case .textRows:
            self = .textRows(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.TextRows.self))
        case .group:
            self = .group(try decoder.singleValueContainer().decode([String: AdaptyUI.ViewItem].self))
        default:
            self = .unknown("item.type: \(type)")
        }
    }
}
