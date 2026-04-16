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

        if container.exist(.function) {
            let function = try container.decode(String.self, forKey: .function)
            let path = function.split(separator: ".").map(String.init)
            guard path.isNotEmpty else {
                throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath + [CodingKeys.function], debugDescription: "not found function name"))
            }
            try self.init(
                path: path,
                params: container.decodeIfPresent([String: Schema.AnyValue].self, forKey: .params),
                scope: container.decodeIfPresent(Schema.Context.self, forKey: .scope) ?? .default
            )
        } else {
            try self.init(fromLegacy: decoder)
        }
    }
}

extension KeyedDecodingContainer {
    func decodeActions(forKey key: Key) throws -> [Schema.Action] {
        if let action = try? decode(Schema.Action.self, forKey: key) {
            [action]
        } else {
            try decode([Schema.Action].self, forKey: key)
        }
    }

    func decodeIfPresentActions(forKey key: Key) throws -> [Schema.Action]? {
        if let action = try? decodeIfPresent(Schema.Action.self, forKey: key) {
            [action]
        } else {
            try decodeIfPresent([Schema.Action].self, forKey: key)
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
                "stringId": VC.AnyValue(container.decode(String.self, forKey: .url)),
            ], scope: .global)
        case "restore":
            self.init(path: ["SDK", "restorePurchases"], params: nil, scope: .global)
        case "close":
            self.init(path: ["SDK", "closeAll"], params: nil, scope: .global)
        case "custom":
            try self.init(path: ["SDK", "userCustomAction"], params: [
                "userCustomId": VC.AnyValue(container.decode(String.self, forKey: .customId)),
            ], scope: .global)
        case "purchase_product":
            try self.init(path: ["SDK", "purchaseProduct"], params: [
                "productId": VC.AnyValue(container.decode(String.self, forKey: .productId)),
            ], scope: .global)
        case "web_purchase_product":
            try self.init(path: ["SDK", "webPurchaseProduct"], params: [
                "productId": VC.AnyValue(container.decode(String.self, forKey: .productId)),
                "openIn": VC.AnyValue(container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn),
            ], scope: .global)
        case "open_screen":
            try self.init(path: ["SDK", "openScreen"], params: [
                "type": VC.AnyValue(container.decode(String.self, forKey: .screenType)),
                "instanceId": VC.AnyValue("legacy-bottom-sheet"),
                "navigatorId": VC.AnyValue("legacy-bottom-sheet"),
                "transitionId": VC.AnyValue("on_appear"),
            ], scope: .global)
        case "close_screen":
            self.init(path: ["SDK", "closeScreen"], params: [
                "navigatorId": VC.AnyValue("legacy-bottom-sheet"),
            ], scope: .global)
        case "select_product":
            try self.init(path: ["Legacy", "selectProduct"], params: [
                "productId": VC.AnyValue(container.decode(String.self, forKey: .productId)),
                "groupId": VC.AnyValue(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId),
            ], scope: .global)
        case "unselect_product":
            try self.init(path: ["Legacy", "unselectProduct"], params: [
                "groupId": VC.AnyValue(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId),
            ], scope: .global)
        case "purchase_selected_product":
            try self.init(path: ["Legacy", "purchaseSelectedProduct"], params: [
                "groupId": VC.AnyValue(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId),
            ], scope: .global)
        case "web_purchase_selected_product":
            try self.init(path: ["Legacy", "webPurchaseSelectedProduct"], params: [
                "groupId": VC.AnyValue(container.decodeIfPresent(String.self, forKey: .groupId) ?? defaultGroupId),
                "openIn": VC.AnyValue(container.decodeIfPresent(String.self, forKey: .openIn) ?? defaultOpenIn),
            ], scope: .global)
        case "switch":
            try self.init(path: ["Legacy", "switchSection"], params: [
                "sectionId": VC.AnyValue(container.decode(String.self, forKey: .sectionId)),
                "index": VC.AnyValue(container.decode(Int.self, forKey: .index)),
            ], scope: .global)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath + [LegacyCodingKeys.type], debugDescription: "unknown value"))
        }
    }
}

