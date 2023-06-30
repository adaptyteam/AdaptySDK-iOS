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
        let common: [String: AdaptyUI.ViewItem]?
        let custom: [String: AdaptyUI.ViewItem]?

        var isEmpty: Bool {
            (common?.isEmpty ?? true) && (custom?.isEmpty ?? true)
        }
    }

    enum ViewItem {
        case asset(String)
        case shape(Shape)
        case button(Button)
        case text(Text)
        case textRows(TextRows)
        case unknown(String?)
    }
}

extension AdaptyUI.ViewStyle: Decodable {
    enum CodingKeys: String, CodingKey {
        case customProperties = "custom_properties"
    }

    init(from decoder: Decoder) throws {
        let single = try decoder.singleValueContainer()

        var common = try single.decode([String: AdaptyUI.ViewItem].self)
        common.removeValue(forKey: CodingKeys.customProperties.rawValue)
        self.common = common.isEmpty ? nil : common

        let container = try decoder.container(keyedBy: CodingKeys.self)
        custom = try container.decodeIfPresent([String: AdaptyUI.ViewItem].self, forKey: .customProperties)
    }
}

extension AdaptyUI.ViewItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
    }

    enum ContentType: String, Codable {
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
        guard let type = try container.decodeIfPresent(String.self, forKey: .type) else {
            self = .unknown(nil)
            return
        }
        switch ContentType(rawValue: type) {
        case .shape:
            self = .shape(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Shape.self))
        case .button:
            self = .button(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Button.self))
        case .text:
            self = .text(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.Text.self))
        case .textRows:
            self = .textRows(try decoder.singleValueContainer().decode(AdaptyUI.ViewItem.TextRows.self))
        default:
            self = .unknown("item.type: \(type)")
        }
    }
}
