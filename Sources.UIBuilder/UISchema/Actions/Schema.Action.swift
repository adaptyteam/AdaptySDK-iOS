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
        case scope
    }

    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.function) {
            let function = try container.decode(String.self, forKey: .function)
            let path = function.split(separator: ".").map(String.init)
            guard !path.isEmpty else {
                throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath + [CodingKeys.function], debugDescription: "not found function name"))
            }
            try self.init(
                path: path,
                params: container.decodeIfPresent([String: Parameter].self, forKey: .params),
                scope: container.decodeIfPresent(Schema.Context.self, forKey: .scope) ?? .default
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
        case screenType = "screen_id"
        case index
    }

    init(fromLegacy decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LegacyCodingKeys.self)

        let defaultOpenIn = WebOpenInParameter.browserOutApp.rawValue
        let defaultGroupId = "group_A"

        switch try container.decode(String.self, forKey: .type) {
        case "open_url":
            try self.init(path: ["SDK", "openUrl"], params: [
                "url": .string(container.decode(String.self, forKey: .url))
            ], scope: .global)
        case "restore":
            self.init(path: ["SDK", "restorePurchases"], params: nil, scope: .global)
        case "close":
            self.init(path: ["SDK", "closeAll"], params: nil, scope: .global)
        case "custom":
            try self.init(path: ["SDK", "userCustomAction"], params: [
                "userCustomId": .string(container.decode(String.self, forKey: .customId))
            ], scope: .global)
        case "web_purchase_paywall":
            try self.init(path: ["SDK", "webPurchasePaywall"], params: [
                "openIn": .string(container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn)
            ], scope: .global)
        case "purchase_product":
            try self.init(path: ["SDK", "purchaseProduct"], params: [
                "productId": .string(container.decode(String.self, forKey: .productId))
            ], scope: .global)
        case "web_purchase_product":
            try self.init(path: ["SDK", "webPurchaseProduct"], params: [
                "productId": .string(container.decode(String.self, forKey: .productId)),
                "openIn": .string(container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn)
            ], scope: .global)
        case "open_screen":
            try self.init(path: ["SDK", "openScreen"], params: [
                "type": .string(container.decode(String.self, forKey: .screenType)),
                "instanceId": .string("legacy-bottom-sheet"),
                "navigatorId": .string("legacy-bottom-sheet")
            ], scope: .global)
        case "close_screen":
            self.init(path: ["SDK", "closeScreen"], params: [
                "navigatorId": .string("legacy-bottom-sheet")
            ], scope: .global)
        case "select_product":
            try self.init(path: ["Legacy", "selectProduct"], params: [
                "productId": .string(container.decode(String.self, forKey: .productId)),
                "groupId": .string(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId)
            ], scope: .global)
        case "unselect_product":
            try self.init(path: ["Legacy", "unselectProduct"], params: [
                "groupId": .string(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId)
            ], scope: .global)
        case "purchase_selected_product":
            try self.init(path: ["Legacy", "purchaseSelectedProduct"], params: [
                "groupId": .string(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId)
            ], scope: .global)
        case "web_purchase_selected_product":
            try self.init(path: ["Legacy", "webPurchaseSelectedProduct"], params: [
                "groupId": .string(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId),
                "openIn": .string(container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn)
            ], scope: .global)
        case "switch":
            try self.init(path: ["Legacy", "switchSection"], params: [
                "sectionId": .string(container.decode(String.self, forKey: .sectionId)),
                "index": .int32(container.decode(Int32.self, forKey: .index))
            ], scope: .global)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath + [LegacyCodingKeys.type], debugDescription: "unknown value"))
        }
    }
}
