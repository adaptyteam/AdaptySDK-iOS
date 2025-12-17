//
//  Schema.Action.swift
//  AdaptyUIBuilder
//
//  Created by Aleksei Valiano on 28.03.2024
//

import Foundation

extension Schema {
    typealias Action = VC.Action
}

extension Schema.Action: Decodable {
    private enum CodingKeys: String, CodingKey {
        case function = "func"
        case params
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.function) {
            try self.init(
                function: container.decode(String.self, forKey: .function),
                params: container.decodeIfPresent([String: String].self, forKey: .params)
            )
        } else {
            try self.init(fromLegacy: decoder)
        }
    }
}

extension Schema.Action {
    private enum LegacyCodingKeys: String, CodingKey {
        case type
        case url
        case customId = "custom_id"
        case productId = "product_id"
        case groupId = "group_id"
        case openIn = "open_in"
        case sectionId = "section_id"
        case screenId = "screen_id"
        case index
    }

    init(fromLegacy decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LegacyCodingKeys.self)

        let defaultOpenIn = WebOpenInParameter.browserOutApp.rawValue
        let defaultGroupId = "group_A"

        switch try container.decode(String.self, forKey: .type) {
        case "open_url":
            try self.init(function: "SDK.openUrl", params: [
                "url": container.decode(String.self, forKey: .url)
            ])
        case "restore":
            self.init(function: "SDK.restorePurchases", params: nil)
        case "close":
            self.init(function: "SDK.closeAll", params: nil)
        case "custom":
            try self.init(function: "SDK.userCustomAction", params: [
                "userCustomId": container.decode(String.self, forKey: .customId)
            ])
        case "web_purchase_paywall":
            try self.init(function: "SDK.webPurchasePaywall", params: [
                "openIn": container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn
            ])
        case "purchase_product":
            try self.init(function: "SDK.purchaseProduct", params: [
                "productId": container.decode(String.self, forKey: .productId)
            ])
        case "web_purchase_product":
            try self.init(function: "SDK.webPurchaseProduct", params: [
                "productId": container.decode(String.self, forKey: .productId),
                "openIn": container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn
            ])
        case "open_screen":
            try self.init(function: "SDK.openScreen", params: [
                "screenId": container.decode(String.self, forKey: .screenId)
            ])
        case "close_screen":
            self.init(function: "SDK.closeCurrentScreen", params: nil)
        case "select_product":
            try self.init(function: "Legacy.selectProduct", params: [
                "productId": container.decode(String.self, forKey: .productId),
                "groupId": container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId
            ])
        case "unselect_product":
            try self.init(function: "Legacy.unselectProduct", params: [
                "groupId": container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId
            ])
        case "purchase_selected_product":
            try self.init(function: "Legacy.purchaseSelectedProduct", params: [
                "groupId": container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId
            ])
        case "web_purchase_selected_product":
            try self.init(function: "Legacy.webPurchaseSelectedProduct", params: [
                "groupId": container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId,
                "openIn": container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn
            ])
        case "switch":
            try self.init(function: "Legacy.switchSection", params: [
                "sectionId": container.decode(String.self, forKey: .sectionId),
                "index": String(container.decode(Int.self, forKey: .index))
            ])
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath + [LegacyCodingKeys.type], debugDescription: "unknown value"))
        }
    }
}
